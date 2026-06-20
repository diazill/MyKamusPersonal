import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class UpdateDialog extends StatefulWidget {
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool isMandatory;

  const UpdateDialog({
    super.key,
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    this.isMandatory = false,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusMessage = 'Menunggu instruksi...';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Mempersiapkan unduhan...';
    });

    try {
      final dio = Dio();
      
      // Get the appropriate directory to save the file
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
      } else {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }
      
      // Get the file extension and name
      String fileName = widget.downloadUrl.split('/').last;
      if (!fileName.contains('.')) {
        fileName = Platform.isAndroid ? 'update.apk' : 'update.exe';
      }
      
      String savePath = '${dir.path}/$fileName';

      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _statusMessage = 'Mengunduh... ${(_progress * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      setState(() {
        _statusMessage = 'Unduhan Selesai! Membuka file...';
      });

      // Open the downloaded file to install
      final result = await OpenFile.open(savePath);
      if (result.type != ResultType.done) {
        setState(() {
          _statusMessage = 'Gagal membuka file: ${result.message}';
        });
      } else {
        // If it's not mandatory, we can close the dialog
        if (!widget.isMandatory && mounted) {
          Navigator.of(context).pop();
        }
      }

    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Gagal mengunduh: $e';
        _progress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isMandatory && !_isDownloading,
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Update Tersedia (v${widget.latestVersion})'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apa yang baru:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(widget.releaseNotes),
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ] else if (_statusMessage.startsWith('Gagal')) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ]
          ],
        ),
        actions: [
          if (!widget.isMandatory && !_isDownloading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
            ),
          if (!_isDownloading)
            ElevatedButton(
              onPressed: _startDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Download & Update'),
            ),
        ],
      ),
    );
  }
}
