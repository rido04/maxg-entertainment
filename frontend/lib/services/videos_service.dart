import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class VideoService {
  static const String _baseUrl =
      'http://192.168.1.9:8000'; // ganti dengan IP real device jika butuh

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
      throw Exception('Failed to load music');
    }
  }
}
