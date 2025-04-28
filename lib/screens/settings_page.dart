import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  final double ttsSpeed;
  final Function(double) onTtsSpeedChanged;
  final String ttsVoice;
  final Function(String) onTtsVoiceChanged;
  final String ttsQuality;
  final Function(String) onTtsQualityChanged;

  const SettingsPage({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.ttsSpeed,
    required this.onTtsSpeedChanged,
    required this.ttsVoice,
    required this.onTtsVoiceChanged,
    required this.ttsQuality,
    required this.onTtsQualityChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode;
  late double _ttsSpeed;
  late String _ttsVoice;
  late String _ttsQuality;

  final List<String> _voices = ['Default', 'Voice 1', 'Voice 2', 'Voice 3'];
  final List<String> _qualities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _ttsSpeed = widget.ttsSpeed;
    _ttsVoice = widget.ttsVoice;
    _ttsQuality = widget.ttsQuality;
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
              labelText: 'TTS Quality',
              border: OutlineInputBorder(),
            ),
            value: _ttsQuality,
            items: _qualities
                .map((quality) => DropdownMenuItem(
                      value: quality,
                      child: Text(quality),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _ttsQuality = value;
                });
                widget.onTtsQualityChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
