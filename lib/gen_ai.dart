import 'package:flutter/services.dart';

class GenAI {
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.flutter.flutter_gen_ai_demo/channel/method');
  static const EventChannel _eventChannel =
      EventChannel('com.example.flutter.flutter_gen_ai_demo/channel/event');

  static Future<String> load(String path) async {
    return await _methodChannel.invokeMethod('load', path);
  }

  static Future<String> inference(String prompt,
      {Map<String, double>? params}) async {
    return await _methodChannel.invokeMethod('inference', {
      'prompt': prompt,
      'params': params,
    });
  }

  static Future<String> unload() async {
    return await _methodChannel.invokeMethod('unload');
  }

  static Stream<String> get tokenStream {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString());
  }
}
