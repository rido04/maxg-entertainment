import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import '../services/global_audio_service.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize global audio service
    GlobalAudioService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: widget.child),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
