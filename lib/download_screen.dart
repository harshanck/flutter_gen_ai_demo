import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'file_helpers.dart';
import 'models.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _State();
}

class _State extends State<DownloadScreen> {
  final Dio _dio = Dio();
  int _currentDownloadIndex = 0;
  int _received = 0;
  int _total = 0;
  bool _isDownloading = false;
  String _downloadResult = "";

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _received = 0;
      _total = 0;
    });

    try {
      for (String url in Models.getModel().files) {
        _currentDownloadIndex = Models.getModel().files.indexOf(url);
        String fileName = url.split('/').last;
        await _downloadFile(url, fileName);
      }
      setState(() {
        _downloadResult = 'Download complete!';
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _downloadResult = 'Download failed: $e';
        _isDownloading = false;
      });
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    final dirPath = await getModelPath();
    final filePath = '$dirPath/$fileName';

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            _received = received;
            _total = total;
          });
        }
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Model'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: _buildBody(),
        ),
      ),
    );
  }

  double get _progress {
    if (_total == 0) {
      return 0;
    }
    return _received / _total;
  }

  _buildBody() {
    if (_downloadResult.isNotEmpty) {
      return Center(child: Text(_downloadResult));
    }
    if (_isDownloading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Downloading files for ${Models.getModel().name}. '
              'Do not close.'),
          const SizedBox(height: 8),
          Text('File ${_currentDownloadIndex + 1} '
              'of ${Models.getModel().files.length}'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text('${(_progress * 100).toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          Text('$_received / $_total'),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'These model files are often large, typically in the range of gigabytes. '
            'Please ensure you are connected to WiFi or a stable internet connection. '
            'Additionally, make sure your device has enough storage space and sufficient memory to run the model.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startDownload,
            child: const Text('Start Download'),
          )
        ],
      );
    }
  }
}
