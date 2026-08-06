// lib/screens/music_screen.dart - Enhanced version matching blade template
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/music_service.dart';
import '../services/global_audio_service.dart';
import '../screens/music_player.dart';
import '../screens/music_search_screen.dart';
import '../screens/all_artist_screen.dart';
import '../screens/artist_detail_screen.dart';
import 'dart:io';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late Future<List<MediaItem>> _musicFuture;
  final MusicService _musicService = MusicService();
  final GlobalAudioService _globalAudioService = GlobalAudioService();
  Map<int, bool> _downloadStatus = {};
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _musicFuture = _loadMusic();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  Future<List<MediaItem>> _loadMusic() async {
    final musicList = await _musicService.fetchMusic();

    // Check download status for each music
    for (final music in musicList) {
      final isDownloaded = await _musicService.isMusicDownloaded(music);
      setState(() {
        _downloadStatus[music.id] = isDownloaded;
      });
    }

    return musicList;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/Background_Color.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Enhanced Header with greeting (matching blade template)
            SliverAppBar(
              expandedHeight: isLandscape ? 120 : 140,
              floating: false,
              pinned: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 56 : 32,
                      vertical: isLandscape ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: isLandscape ? 160 : 240,
                              height: isLandscape ? 32 : 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                'assets/images/logo/Maxg-ent_white.gif',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD97706),
                                    Color(0xFFD97706),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD97706,
                                    ).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    setState(() {
                                      _musicFuture = _loadMusic();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sync Music',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lagi Bosen dan pengen ngelamun?, dengerin koleksi musik kami aja!',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: isLandscape ? 12 : 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar (matching blade template style)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 56 : 32,
                    vertical: 16,
                  ),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const MusicSearchScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: animation.drive(
                                          Tween(
                                            begin: const Offset(0.0, 0.1),
                                            end: Offset.zero,
                                          ).chain(
                                            CurveTween(curve: Curves.easeOut),
                                          ),
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Search for songs...',
                                style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content sections
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 56 : 32,
                vertical: 8,
              ),
              sliver: FutureBuilder<List<MediaItem>>(
                future: _musicFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFD97706),
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Loading your music...',
                              style: TextStyle(
                                color: Colors.grey[200],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Oops! Something went wrong',
                              style: TextStyle(
                                color: Colors.grey[200],
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final musicList = snapshot.data!;

                  if (musicList.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: Colors.white.withOpacity(0.5),
                                size: 50,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No music found',
                              style: TextStyle(
                                color: Colors.grey[200],
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Quick Access Section
                      _buildQuickAccessSection(musicList, isTablet),
                      const SizedBox(height: 32),

                      // Featured Artists Section
                      _buildFeaturedArtistsSection(musicList, isTablet),
                      const SizedBox(height: 32),

                      // Recently Played Section
                      _buildRecentlyPlayedSection(musicList, isTablet),
                      const SizedBox(height: 32),

                      // All Songs Section
                      _buildAllSongsSection(musicList, isTablet),
                      const SizedBox(height: 100),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(List<MediaItem> musicList, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            color: const Color(0xFFD97706),
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: musicList.take(6).length,
          itemBuilder: (context, index) {
            final music = musicList[index];
            return _buildQuickAccessCard(music, isTablet);
          },
        ),
      ],
    );
  }

  Widget _buildThumbnailImage(MediaItem music, bool isTablet) {
    // Check if it's local file path
    if (music.thumbnail!.startsWith('/')) {
      return Image.file(
        File(music.thumbnail!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildThumbnailPlaceholder(music, isTablet),
      );
    } else {
      // It's network URL
      return Image.network(
        music.thumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildThumbnailPlaceholder(music, isTablet),
      );
    }
  }

  Widget _buildQuickAccessCard(MediaItem music, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _playMusic(music),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 50 : 48,
                  height: isTablet ? 50 : 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        music.thumbnail != null && music.thumbnail!.isNotEmpty
                        ? _buildThumbnailImage(music, isTablet)
                        : _buildThumbnailPlaceholder(music, isTablet),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        music.title,
                        style: TextStyle(
                          color: const Color(0xFF1F2937),
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        music.artist ?? 'Unknown Artist',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: isTablet ? 14 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  'More',
                  style: TextStyle(
                    color: const Color(0xFFD97706),
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedArtistsSection(
    List<MediaItem> musicList,
    bool isTablet,
  ) {
    // Get unique artists
    final uniqueArtists = musicList
        .where((music) => music.artist != null && music.artist!.isNotEmpty)
        .map((music) => music.artist!)
        .toSet()
        .take(10)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Artists',
              style: TextStyle(
                color: const Color(0xFFD97706),
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AllArtistsScreen(musicList: musicList),
                  ),
                );
              },
              child: const Text(
                'Show all',
                style: TextStyle(
                  color: Color(0xFF005572),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isTablet ? 200 : 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: uniqueArtists.length,
            itemBuilder: (context, index) {
              final artist = uniqueArtists[index];
              final artistSong = musicList.firstWhere(
                (music) => music.artist == artist,
              );
              return _buildArtistCard(artist, artistSong, musicList, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtistCard(
    String artist,
    MediaItem artistSong,
    List<MediaItem> allMusic,
    bool isTablet,
  ) {
    return Container(
      width: isTablet ? 160 : 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistDetailScreen(
                    artistName: artist,
                    musicList: allMusic
                        .where((m) => m.artist == artist)
                        .toList(),
                  ),
                ),
              );
            },
            child: Container(
              width: isTablet ? 128 : 96,
              height: isTablet ? 128 : 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFEC4899)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    artistSong.thumbnail != null &&
                        artistSong.thumbnail!.isNotEmpty
                    ? _buildThumbnailImage(artistSong, isTablet)
                    : _buildArtistPlaceholder(artist, isTablet),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            artist.length > 15 ? '${artist.substring(0, 15)}...' : artist,
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Artist',
            style: TextStyle(
              color: Colors.grey[200]?.withOpacity(0.8),
              fontSize: isTablet ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayedSection(List<MediaItem> musicList, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently played',
          style: TextStyle(
            color: const Color(0xFFD97706),
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isTablet ? 260 : 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: musicList.take(8).length,
            itemBuilder: (context, index) {
              final music = musicList[index];
              return _buildRecentlyPlayedCard(music, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayedCard(MediaItem music, bool isTablet) {
    return Container(
      width: isTablet ? 200 : 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _playMusic(music),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: isTablet ? 160 : 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        music.thumbnail != null && music.thumbnail!.isNotEmpty
                        ? _buildThumbnailImage(music, isTablet)
                        : _buildThumbnailPlaceholder(music, isTablet),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  music.title.length > 20
                      ? '${music.title.substring(0, 20)}...'
                      : music.title,
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (music.artist != null) ...[
                  Text(
                    music.artist!.length > 15
                        ? '${music.artist!.substring(0, 15)}...'
                        : music.artist!,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: isTablet ? 12 : 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllSongsSection(List<MediaItem> musicList, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Made for you',
          style: TextStyle(
            color: const Color(0xFFD97706),
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header for desktop/tablet
              if (isTablet) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50]?.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '#',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: Text(
                          'Title',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Artist',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Center(
                          child: Icon(
                            Icons.access_time,
                            color: const Color(0xFF6B7280),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.withOpacity(0.3), height: 1),
              ],

              // Songs list
              Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: musicList.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey.withOpacity(0.1), height: 1),
                  itemBuilder: (context, index) {
                    final music = musicList[index];
                    return _buildSongListItem(music, index + 1, isTablet);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSongListItem(MediaItem music, int index, bool isTablet) {
    return AnimatedBuilder(
      animation: _globalAudioService,
      builder: (context, child) {
        final isCurrentlyPlaying =
            _globalAudioService.currentMusic?.id == music.id;
        final isPlaying =
            _globalAudioService.player.playing && isCurrentlyPlaying;

        return Container(
          decoration: BoxDecoration(
            color: isCurrentlyPlaying
                ? const Color(0xFFD97706).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MusicPlayer(music: music),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(0.0, 1.0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                            ),
                            child: child,
                          );
                        },
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 12 : 8,
                ),
                child: isTablet
                    ? Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              index.toString(),
                              style: TextStyle(
                                color: isCurrentlyPlaying
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child:
                                  music.thumbnail != null &&
                                      music.thumbnail!.isNotEmpty
                                  ? _buildThumbnailImage(music, isTablet)
                                  : _buildThumbnailPlaceholder(music, isTablet),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music.title,
                                  style: TextStyle(
                                    color: isCurrentlyPlaying
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF1F2937),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (music.album != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    music.album!,
                                    style: TextStyle(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              music.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!(_downloadStatus[music.id] ?? false)) ...[
                                  IconButton(
                                    icon: Icon(
                                      Icons.download_rounded,
                                      color: const Color(0xFF6B7280),
                                      size: 18,
                                    ),
                                    onPressed: () => _downloadMusic(music),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  music.duration != null
                                      ? _formatDuration(music.duration!)
                                      : '3:45',
                                  style: TextStyle(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child:
                                  music.thumbnail != null &&
                                      music.thumbnail!.isNotEmpty
                                  ? _buildThumbnailImage(music, isTablet)
                                  : _buildThumbnailPlaceholder(music, isTablet),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music.title,
                                  style: TextStyle(
                                    color: isCurrentlyPlaying
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF1F2937),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  music.artist ?? 'Unknown Artist',
                                  style: TextStyle(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (music.album != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    music.album!,
                                    style: TextStyle(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              if (!(_downloadStatus[music.id] ?? false)) ...[
                                IconButton(
                                  icon: Icon(
                                    Icons.download_rounded,
                                    color: const Color(0xFF6B7280),
                                    size: 16,
                                  ),
                                  onPressed: () => _downloadMusic(music),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                music.duration != null
                                    ? _formatDuration(music.duration!)
                                    : '3:45',
                                style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailPlaceholder(MediaItem music, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: isTablet ? 24 : 20,
        ),
      ),
    );
  }

  Widget _buildArtistPlaceholder(String artist, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: isTablet ? 48 : 40,
        ),
      ),
    );
  }

  Future<void> _playMusic(MediaItem music) async {
    try {
      final isCurrentlyPlaying =
          _globalAudioService.currentMusic?.id == music.id;
      final isPlaying =
          _globalAudioService.player.playing && isCurrentlyPlaying;

      if (isCurrentlyPlaying) {
        if (isPlaying) {
          await _globalAudioService.pause();
        } else {
          await _globalAudioService.play();
        }
      } else {
        await _globalAudioService.playMusic(music);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to play: $e');
    }
  }

  Future<void> _downloadMusic(MediaItem music) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD97706),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Downloading',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                music.title,
                style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

      final downloadDir = await _musicService.getDownloadDirectory();
      await _musicService.downloadMusicFile(music, downloadDir);

      setState(() {
        _downloadStatus[music.id] = true;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Download completed!',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      music.title,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorSnackBar(context, 'Failed to download: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  double get minExtent => 88;

  @override
  double get maxExtent => 88;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
