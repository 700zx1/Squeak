import 'package:flutter/material.dart';
import '../services/sharing_service.dart';
import '../services/tts_service.dart';
import '../services/parsing_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _content = "\ud83d\udcc4 Waiting for shared content...";
  bool _isLoading = false;

  Future<void> _pickAndParseFile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'html', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final ext = file.path.split('.').last.toLowerCase();
        String parsed = '';
        if (ext == 'pdf') {
          parsed = await ParsingService.parsePDF(file);
        } else if (ext == 'epub') {
          parsed = await ParsingService.parseEPUB(file);
        } else if (ext == 'html') {
          parsed = await ParsingService.parseHTML(await file.readAsString());
        } else if (ext == 'txt') {
          parsed = await ParsingService.parsePlainText(await file.readAsString());
        } else {
          parsed = 'Unsupported file type.';
        }
        setState(() {
          _content = parsed.isNotEmpty ? parsed : 'No readable content found.';
        });
        if (parsed.isNotEmpty) {
          TTSService.speak(parsed);
        }
      }
    } catch (e) {
      setState(() {
        _content = 'Failed to parse file: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse file: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SharingService.init((sharedData) async {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _content = sharedData;
        _isLoading = false;
      });
      TTSService.speak(sharedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squeak Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History (Coming Soon)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings (Coming Soon)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Pick a file'),
                        onPressed: _pickAndParseFile,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                        onPressed: () => TTSService.speak(_content),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        onPressed: () => TTSService.pause(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        onPressed: () => TTSService.stop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(child: Text(_content)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
