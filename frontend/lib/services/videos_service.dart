import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class VideoService {
  static const String _baseUrl =
      'https://maxg.app.medialoger.com'; // ganti dengan IP real device jika butuh

  Future<List<MediaItem>> fetchMusic() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/media'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      final musicItems = data
          .where((item) => item['type'] == 'video')
          .map((json) => MediaItem.fromJson(json))
          .toList();
      return musicItems;
    } else {
      throw Exception('Failed to load Movie');
    }
  }
}
