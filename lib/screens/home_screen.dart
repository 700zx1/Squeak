import 'package:flutter/material.dart';
import '../services/sharing_service.dart';
import '../services/tts_service.dart';
import '../services/parsing_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Add this import for compute
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import 'settings_page.dart';

// Add this helper function outside the class
Future<String> parseFileInBackground(Map<String, dynamic> args) async {
  final File file = args['file'];
  final String ext = args['ext'];

  if (ext == 'pdf') {
    return await ParsingService.parsePDF(file);
  } else if (ext == 'epub') {
    return await ParsingService.parseEPUB(file);
  } else if (ext == 'html') {
    return await ParsingService.parseHTML(await file.readAsString());
  } else if (ext == 'txt') {
    return await ParsingService.parsePlainText(await file.readAsString());
  } else {
    return 'Unsupported file type.';
  }
}

// Fetch webpage content
Future<String> fetchWebpageContent(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body; // Return raw HTML content
    } else {
      return 'Failed to fetch webpage content. Status code: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error fetching webpage content: $e';
  }
}

// Extract readable text from HTML
String extractTextFromHtml(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  return document.body?.text ?? 'No readable content found.';
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomeScreen({
    Key? key,
    this.isDarkMode = false,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _content = "\ud83d\udcc4 Waiting for shared content...";
  bool _isLoading = false;

  double _ttsSpeed = 1.0;
  String _ttsVoice = 'Default';
  String _ttsEngine = 'Default';

  late final SharingService _sharingService;
  StreamSubscription<String>? _sharedTextSub;

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

        // Use compute to parse the file in a background thread
        final parsed = await compute(parseFileInBackground, {'file': file, 'ext': ext});

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
    _sharingService = SharingService();
    _sharingService.initialize();
    _sharedTextSub = _sharingService.sharedTextStream.listen((url) async {
      setState(() {
        _isLoading = true;
        _content = 'Fetching shared webpage...';
      });
      String html = await fetchWebpageContent(url);
      String text = extractTextFromHtml(html);
      setState(() {
        _content = text.isNotEmpty ? text : 'No readable content found.';
        _isLoading = false;
      });
      if (text.isNotEmpty) {
        TTSService.speak(text);
      }
    });
  }

  void _onThemeChanged(bool value) {
    widget.onThemeChanged(value);
  }

  void _onTtsSpeedChanged(double value) {
    setState(() {
      _ttsSpeed = value;
    });
    TTSService.setSpeed(value);
  }

  void _onTtsVoiceChanged(String value) {
    setState(() {
      _ttsVoice = value;
    });
    TTSService.setVoice(value);
  }

  void _onTtsEngineChanged(String value) {
    setState(() {
      _ttsEngine = value;
    });
    TTSService.setEngine(value);
  }

  @override
  void dispose() {
    _sharedTextSub?.cancel();
    super.dispose();
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
                    isDarkMode: widget.isDarkMode,
                    ttsSpeed: _ttsSpeed,
                    ttsVoice: _ttsVoice,
                    ttsEngine: _ttsEngine, // Pass the ttsEngine here
                    onThemeChanged: _onThemeChanged,
                    onTtsSpeedChanged: _onTtsSpeedChanged,
                    onTtsVoiceChanged: _onTtsVoiceChanged,
                    onTtsEngineChanged: _onTtsEngineChanged,
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }
}
