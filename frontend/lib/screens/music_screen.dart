import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/music_service.dart';
import '../screens/music_player.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late Future<List<MediaItem>> _musicFuture;

  @override
  void initState() {
    super.initState();
    _musicFuture = MusicService().fetchMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: FutureBuilder<List<MediaItem>>(
        future: _musicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final musicList = snapshot.data!;

          return ListView.builder(
            itemCount: musicList.length,
            itemBuilder: (context, index) {
              final music = musicList[index];
              return ListTile(
                title: Text(music.title),
                subtitle: Text(music.artist ?? 'Unknown Artist'),
                trailing: Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MusicPlayer(music: music),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
