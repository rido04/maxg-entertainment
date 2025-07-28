import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/media_item.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:8000/api';

  /// Fetch media list
  static Future<List<MediaItem>> fetchMediaList() async {
    final response = await http.get(Uri.parse('$baseUrl/media'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List data = jsonResponse['data'];
      return data.map((item) => MediaItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load media list');
    }
  }

  /// Fetch media items (playlist)
  // static Future<List<MediaItem>> fetchMediaItems() async {
  //   final url = Uri.parse('$baseUrl/media'); // Pastikan endpoint ini sesuai
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((item) => MediaItem.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Failed to load media items');
  //   }
  // }
}
