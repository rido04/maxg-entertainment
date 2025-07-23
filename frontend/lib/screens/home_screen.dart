// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart'; // Tambahkan import ini

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MediaItem>> mediaList;

  @override
  void initState() {
    super.initState();
    mediaList = ApiService.fetchMediaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media List')),
      body: FutureBuilder<List<MediaItem>>(
        future: mediaList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final media = items[index];
                return ListTile(
                  title: Text(media.title),
                  subtitle: Text(media.fileUrl),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      final filename = media.downloadUrl.split('/').last;
                      final downloaded = await isMediaDownloaded(filename);

                      if (downloaded) {
                        final path = await getLocalFilePath(filename);
                        // Play from local path
                        print('Playing from local path: $path');
                      } else {
                        await downloadMedia(media.downloadUrl, filename);
                        // Then play
                        print('Downloaded and playing: $filename');
                      }
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
