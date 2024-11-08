import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String systemPrompt;
  final double? temperature;
  final double? maxLength;
  final double? lengthPenalty;

  const SettingsScreen({
    super.key,
    required this.systemPrompt,
    this.temperature,
    this.maxLength,
    this.lengthPenalty,
  });

  @override
  State<SettingsScreen> createState() => _State();
}

class _State extends State<SettingsScreen> {
  final TextEditingController _systemPromptController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _maxLengthController = TextEditingController();
  final TextEditingController _penaltyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _systemPromptController.text = widget.systemPrompt;
    _temperatureController.text = widget.temperature?.toString() ?? '';
    _maxLengthController.text = widget.maxLength?.toString() ?? '';
    _penaltyController.text = widget.lengthPenalty?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _systemPromptController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'System Prompt',
                  border: OutlineInputBorder(),
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _temperatureController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Temperature',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _maxLengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Length',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _penaltyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Length Penalty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    Navigator.of(context).pop({
      'systemPrompt': _systemPromptController.text,
      'temperature': _temperatureController.text,
      'maxLength': _maxLengthController.text,
      'lengthPenalty': _penaltyController.text,
    });
  }
}
