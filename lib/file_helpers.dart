import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter_gen_ai_demo/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

String _getModelDir() {
  return Models.getModel().path;
}

Future<String> getModelPath() async {
  if (Platform.isIOS) {
    final doc = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${doc.path}/${_getModelDir()}');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir.path;
  } else {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      var docPath = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOCUMENTS);
      final modelDir = Directory('$docPath/${_getModelDir()}');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      return modelDir.path;
    } else {
      throw Exception('Storage permission not granted');
    }
  }
}

Future<bool> isModelFilesExist() async {
  final directory = Directory(await getModelPath());
  if (await directory.exists()) {
    final contents = directory.listSync();
    return contents.isNotEmpty;
  }
  return false;
}
