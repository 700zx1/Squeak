import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  final double ttsSpeed;
  final Function(double) onTtsSpeedChanged;
  final String ttsVoice;
  final Function(String) onTtsVoiceChanged;
  final String ttsEngine;
  final Function(String) onTtsEngineChanged;

  const SettingsPage({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.ttsSpeed,
    required this.onTtsSpeedChanged,
    required this.ttsVoice,
    required this.onTtsVoiceChanged,
    required this.ttsEngine,
    required this.onTtsEngineChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode;
  late double _ttsSpeed;
  late String _ttsVoice;
  late String _ttsEngine;
  bool _isLoading = false;

  final List<String> _voices = ['Default', 'Voice 1', 'Voice 2', 'Voice 3'];
  List<String> _engines = ['Default']; // Placeholder for TTS engines

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _ttsSpeed = widget.ttsSpeed;
    _ttsVoice = widget.ttsVoice;
    _ttsEngine = widget.ttsEngine;

    // Fetch available TTS engines
    _fetchEngines();
  }

  Future<void> _fetchEngines() async {
    setState(() {
      _isLoading = true; // Add a loading state if necessary
    });
    try {
      final engines = await TTSService.getAvailableEngines();
      setState(() {
        _engines = ['Default', ...engines.cast<String>()]; // Ensure 'Default' is included
      });
    } catch (e) {
      print('Error fetching TTS engines: $e');
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              widget.onThemeChanged(value);
            },
          ),
          const SizedBox(height: 20),
          Text('TTS Speed: ${_ttsSpeed.toStringAsFixed(1)}x'),
          Slider(
            value: _ttsSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            label: '${_ttsSpeed.toStringAsFixed(1)}x',
            onChanged: (value) {
              setState(() {
                _ttsSpeed = value;
              });
              widget.onTtsSpeedChanged(value);
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'TTS Voice',
              border: OutlineInputBorder(),
            ),
            value: _ttsVoice,
            items: _voices
                .map((voice) => DropdownMenuItem(
                      value: voice,
                      child: Text(voice),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _ttsVoice = value;
                });
                widget.onTtsVoiceChanged(value);
              }
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'TTS Engine',
              border: OutlineInputBorder(),
            ),
            value: _ttsEngine,
            items: _engines
                .map((engine) => DropdownMenuItem(
                      value: engine,
                      child: Text(engine),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _ttsEngine = value;
                });
                widget.onTtsEngineChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
