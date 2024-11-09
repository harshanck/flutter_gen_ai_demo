import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_demo/models.dart';

import 'download_screen.dart';
import 'file_helpers.dart';
import 'gen_ai.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _State();
}

class _State extends State<ChatScreen> {
  bool _modelDownloaded = false;
  String _modelLoadStatus = "Loading...";
  bool _inferencing = false;
  String _systemPrompt = "You are an AI assistant. Always respond with brief, "
      "concise answers and avoid adding extra commentary.";
  double? _temperature = 0.7;
  double? _maxLength;
  double? _lengthPenalty = 1.0;
  final StringBuffer _tokenBuffer = StringBuffer();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _userPrompt = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() async {
    try {
      _modelDownloaded = await isModelFilesExist();
      setState(() {});
      if (_modelDownloaded) {
        String path = await getModelPath();
        await GenAI.load(path);
        setState(() {
          _modelLoadStatus = "";
        });
      }
    } catch (e) {
      setState(() {
        _modelLoadStatus = "Model load failed: ${e.toString()}";
      });
    }
  }

  void _inference() async {
    setState(() {
      _tokenBuffer.clear();
      _inferencing = true;
    });
    String finalPrompt = "<system>$_systemPrompt<|end|>"
        "<|user|>$_userPrompt<|end|>"
        "<|assistant|>";

    Map<String, double> params = {};
    if (_temperature != null) {
      params["temperature"] = _temperature!;
    }
    if (_maxLength != null) {
      params["max_length"] = _maxLength!;
    }
    if (_lengthPenalty != null) {
      params["length_penalty"] = _lengthPenalty!;
    }
    await GenAI.inference(finalPrompt, params: params);
    setState(() {
      _inferencing = false;
    });
  }

  @override
  void dispose() {
    GenAI.unload();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gen AI Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              _downloadModel();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              Map<String, dynamic>? result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    systemPrompt: _systemPrompt,
                    temperature: _temperature,
                    maxLength: _maxLength,
                    lengthPenalty: _lengthPenalty,
                  ),
                ),
              );
              if (result != null) {
                _systemPrompt = result['systemPrompt'];
                if (result['temperature'] != null) {
                  _temperature = result['temperature'];
                }
                if (result['maxLength'] != null) {
                  _maxLength = result['maxLength'];
                }
                if (result['lengthPenalty'] != null) {
                  _lengthPenalty = result['lengthPenalty'];
                }
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  _downloadModel() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DownloadScreen(),
      ),
    );
    setState(() {
      _modelLoadStatus = "Loading...";
    });
    _load();
  }

  _buildBody() {
    if (!_modelDownloaded) {
      return Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please download model files for ${Models.getModel().name}"),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  _downloadModel();
                },
                child: const Text('Download Model'),
              ),
            ],
          ),
        ),
      );
    }
    if (_modelLoadStatus.isEmpty) {
      return _buildChatUi();
    } else {
      return Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(_modelLoadStatus),
            ],
          ),
        ),
      );
    }
  }

  _buildChatUi() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_userPrompt),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<String>(
              stream: GenAI.tokenStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Text(_inferencing
                        ? 'Inferencing...'
                        : 'Enter your prompt...'),
                  );
                } else {
                  _tokenBuffer.write(snapshot.data!);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  });
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Text(
                      _tokenBuffer.toString(),
                    ),
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Prompt',
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Center(
                  child: _inferencing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          onPressed: () {
                            _userPrompt = _promptController.text;
                            _inference();
                            _promptController.clear();
                          },
                          icon: const Icon(Icons.send),
                        ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
