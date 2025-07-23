import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

/// Ambil path lokal untuk menyimpan file
Future<String> getLocalFilePath(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$filename';
}

/// Cek apakah file sudah diunduh
Future<bool> isMediaDownloaded(String filename) async {
  final path = await getLocalFilePath(filename);
  return File(path).existsSync();
}

/// Unduh file dari internet ke lokal storage
Future<void> downloadMedia(String url, String filename) async {
  final savePath = await getLocalFilePath(filename);
  final dio = Dio();

  try {
    await dio.download(url, savePath);
    print('Download complete: $savePath');
  } catch (e) {
    print('Download failed: $e');
    rethrow;
  }
}
