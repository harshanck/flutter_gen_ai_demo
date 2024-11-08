import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'models.dart';

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  @override
  State<SelectScreen> createState() => _State();
}

class _State extends State<SelectScreen> {
  @override
  void initState() {
    super.initState();
    Models.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Model')),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _selectModel(Models.llama3_2);
                },
                child: const Text('Llama 3.2 1B'),
              ),
              const SizedBox(height: 30),
              const Text(
                "Phi-3.5 Mini model require more memory. "
                "Please test it on a device with more memory.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _selectModel(Models.phi3_5Mini);
                },
                child: const Text('Phi 3.5 Mini'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _selectModel(Model model) {
    Models.setModel(model);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  }
}
