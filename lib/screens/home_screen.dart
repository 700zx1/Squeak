import 'package:flutter/material.dart';
import '../services/sharing_service.dart';
import '../services/tts_service.dart';
import '../services/parsing_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _content = "\ud83d\udcc4 Waiting for shared content...";
  bool _isLoading = false;

  bool _isDarkMode = false;
  double _ttsSpeed = 1.0;
  String _ttsVoice = 'Default';
  String _ttsQuality = 'Medium';

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

  void _onThemeChanged(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: Apply theme change globally
  }

  void _onTtsSpeedChanged(double value) {
    setState(() {
      _ttsSpeed = value;
    });
    // TODO: Apply TTS speed change in TTSService
  }

  void _onTtsVoiceChanged(String value) {
    setState(() {
      _ttsVoice = value;
    });
    // TODO: Apply TTS voice change in TTSService
  }

  void _onTtsQualityChanged(String value) {
    setState(() {
      _ttsQuality = value;
    });
    // TODO: Apply TTS quality change in TTSService
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
            tooltip: 'Settings',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    isDarkMode: _isDarkMode,
                    ttsSpeed: _ttsSpeed,
                    ttsVoice: _ttsVoice,
                    ttsQuality: _ttsQuality,
                    onThemeChanged: _onThemeChanged,
                    onTtsSpeedChanged: _onTtsSpeedChanged,
                    onTtsVoiceChanged: _onTtsVoiceChanged,
                    onTtsQualityChanged: _onTtsQualityChanged,
                  ),
                ),
              );
              if (result != null) {
                // Handle any returned data from settings page if needed
              }
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
