import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_item.dart';

class MusicPlayer extends StatefulWidget {
  final MediaItem music;

  const MusicPlayer({super.key, required this.music});

  @override
  State<MusicPlayer> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayer> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.music.downloadUrl); // mulai load audio
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.music.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final playing = state?.playing ?? false;

                if (state?.processingState == ProcessingState.loading ||
                    state?.processingState == ProcessingState.buffering) {
                  return const CircularProgressIndicator();
                } else if (playing) {
                  return IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.pause),
                    onPressed: _player.pause,
                  );
                } else {
                  return IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.play_arrow),
                    onPressed: _player.play,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
