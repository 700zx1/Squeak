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
import 'package:flutter_html/flutter_html.dart';

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

  // Wikipedia: main content in <div id="mw-content-text">
  final mainDiv = document.querySelector('#mw-content-text');
  if (mainDiv != null) {
    final text = mainDiv.text.trim();
    if (text.isNotEmpty) return text;
  }

  // Fallback: <article>
  final article = document.querySelector('article');
  if (article != null) {
    final text = article.text.trim();
    if (text.isNotEmpty) return text;
  }

  // Fallback: <main>
  final mainTag = document.querySelector('main');
  if (mainTag != null) {
    final text = mainTag.text.trim();
    if (text.isNotEmpty) return text;
  }

  // Fallback: all body text
  final bodyText = document.body?.text.trim() ?? '';
  return bodyText.isNotEmpty ? bodyText : 'No readable content found.';
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
  String _htmlContent = '';
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
          _htmlContent = ext == 'html' && parsed.isNotEmpty ? file.readAsStringSync() : '';
        });

        if (parsed.isNotEmpty) {
          TTSService.speak(parsed);
        }
      }
    } catch (e) {
      setState(() {
        _content = 'Failed to parse file: $e';
        _htmlContent = '';
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
        _htmlContent = '';
      });
      String html = await fetchWebpageContent(url);
      String text = extractTextFromHtml(html);
      setState(() {
        _content = text.isNotEmpty ? text : 'No readable content found.';
        _htmlContent = html;
        _isLoading = false;
      });
      if (text.trim().isNotEmpty) {
        print('Extracted text for TTS:');
        print(text);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          TTSService.speak(text);
        });
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _htmlContent.isNotEmpty
                          ? Html(data: _htmlContent)
                          : Text(
                              _content,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Pick a file'),
                          onPressed: _pickAndParseFile,
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                          onPressed: (_content.isNotEmpty && !_isLoading)
                              ? () {
                                  print('Play button pressed. Content:');
                                  print(_content);
                                  TTSService.speak(_content);
                                }
                              : null,
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          onPressed: () {
                            TTSService.pause();
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          onPressed: () {
                            TTSService.stop();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }
}
