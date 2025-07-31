// lib/screens/music_search_screen.dart - Enhanced Spotify-style version
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/music_service.dart';
import '../services/global_audio_service.dart';
import '../screens/music_player.dart';

class MusicSearchScreen extends StatefulWidget {
  const MusicSearchScreen({super.key});

  @override
  State<MusicSearchScreen> createState() => _MusicSearchScreenState();
}

class _MusicSearchScreenState extends State<MusicSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final MusicService _musicService = MusicService();
  final GlobalAudioService _globalAudioService = GlobalAudioService();

  List<MediaItem> _searchResults = [];
  List<MediaItem> _recentSearches = [];
  List<String> _searchHistory = [];
  Map<int, bool> _downloadStatus = {};
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // Auto focus pada search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    // Simulasi recent searches - dalam implementasi nyata, ini bisa dari local storage
    // Untuk sekarang, kita ambil beberapa musik sebagai recent searches
    try {
      final allMusic = await _musicService.fetchMusic();
      setState(() {
        _recentSearches = allMusic.take(5).toList();
      });

      // Check download status for recent searches
      for (final music in _recentSearches) {
        final isDownloaded = await _musicService.isMusicDownloaded(music);
        setState(() {
          _downloadStatus[music.id] = isDownloaded;
        });
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  Future<void> _searchMusic(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      // Simulasi search - dalam implementasi nyata, ini akan memanggil API search
      final allMusic = await _musicService.fetchMusic();
      final results = allMusic.where((music) {
        final titleMatch = music.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        final artistMatch =
            music.artist?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final albumMatch =
            music.album?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return titleMatch || artistMatch || albumMatch;
      }).toList();

      // Check download status for search results
      for (final music in results) {
        final isDownloaded = await _musicService.isMusicDownloaded(music);
        setState(() {
          _downloadStatus[music.id] = isDownloaded;
        });
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Add to search history
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar(context, 'Search failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Search Field
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: _searchFocusNode.hasFocus
                              ? const Color(0xFF1DB954)
                              : Colors.white.withOpacity(0.2),
                          width: _searchFocusNode.hasFocus ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search songs, artists, albums...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _searchFocusNode.hasFocus
                                ? const Color(0xFF1DB954)
                                : Colors.white.withOpacity(0.6),
                            size: 24,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchMusic('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          // Debounce search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchController.text == value) {
                              _searchMusic(value);
                            }
                          });
                        },
                        onSubmitted: _searchMusic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildContent(isTablet)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isTablet) {
    if (_isSearching) {
      return _buildLoadingState();
    }

    if (_hasSearched) {
      if (_searchResults.isEmpty) {
        return _buildNoResultsState();
      }
      return _buildSearchResults(isTablet);
    }

    return _buildInitialState(isTablet);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1DB954),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Searching...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
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
              Icons.search_off_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No results found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History
          if (_searchHistory.isNotEmpty) ...[
            Text(
              'Recent searches',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((query) {
                return InkWell(
                  onTap: () {
                    _searchController.text = query;
                    _searchMusic(query);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: Colors.white.withOpacity(0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          query,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Recent Searches (Music)
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent music',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final music = _recentSearches[index];
                return _buildMusicTile(music, isTablet);
              },
            ),
          ],

          // Popular Genres/Categories
          const SizedBox(height: 32),
          Text(
            'Browse by genre',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: [
              _buildGenreTile('Pop', const Color(0xFFE13eca)),
              _buildGenreTile('Rock', const Color(0xFF8b1e0a)),
              _buildGenreTile('Jazz', const Color(0xFF1e3264)),
              _buildGenreTile('Electronic', const Color(0xFF1db954)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreTile(String genre, Color color) {
    return InkWell(
      onTap: () {
        _searchController.text = genre;
        _searchMusic(genre);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            genre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 16,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final music = _searchResults[index];
        return _buildMusicTile(music, isTablet);
      },
    );
  }

  Widget _buildMusicTile(MediaItem music, bool isTablet) {
    final isDownloaded = _downloadStatus[music.id] ?? false;

    return AnimatedBuilder(
      animation: _globalAudioService,
      builder: (context, child) {
        final isCurrentlyPlaying =
            _globalAudioService.currentMusic?.id == music.id;
        final isPlaying =
            _globalAudioService.player.playing && isCurrentlyPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: isCurrentlyPlaying
                ? LinearGradient(
                    colors: [
                      const Color(0xFF1DB954).withOpacity(0.15),
                      const Color(0xFF1ED760).withOpacity(0.05),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentlyPlaying
                  ? const Color(0xFF1DB954).withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
              width: isCurrentlyPlaying ? 1.5 : 1,
            ),
            boxShadow: isCurrentlyPlaying
                ? [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20,
              vertical: isTablet ? 16 : 12,
            ),
            leading: _buildMusicThumbnail(
              music,
              isCurrentlyPlaying,
              isPlaying,
              isTablet,
            ),
            title: Text(
              music.title,
              style: TextStyle(
                color: isCurrentlyPlaying
                    ? const Color(0xFF1DB954)
                    : Colors.white,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  music.artist ?? 'Unknown Artist',
                  style: TextStyle(
                    color: isCurrentlyPlaying
                        ? const Color(0xFF1DB954).withOpacity(0.8)
                        : Colors.white.withOpacity(0.7),
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (music.album != null && music.album!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    music.album!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: isTablet ? 13 : 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDownloaded) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.download_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: isTablet ? 22 : 20,
                      ),
                      onPressed: () => _downloadMusic(music),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isCurrentlyPlaying && isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: isTablet ? 28 : 24,
                    ),
                    onPressed: () async {
                      if (isCurrentlyPlaying) {
                        if (isPlaying) {
                          await _globalAudioService.pause();
                        } else {
                          await _globalAudioService.play();
                        }
                      } else {
                        try {
                          await _globalAudioService.playMusic(music);
                        } catch (e) {
                          _showErrorSnackBar(context, 'Failed to play: $e');
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
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
          ),
        );
      },
    );
  }

  Widget _buildMusicThumbnail(
    MediaItem music,
    bool isCurrentlyPlaying,
    bool isPlaying,
    bool isTablet,
  ) {
    return Container(
      width: isTablet ? 70 : 60,
      height: isTablet ? 70 : 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: music.thumbnail != null && music.thumbnail!.isNotEmpty
            ? Stack(
                children: [
                  Image.network(
                    music.thumbnail!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultThumbnail(
                        music,
                        isCurrentlyPlaying,
                        isPlaying,
                        isTablet,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  if (isCurrentlyPlaying)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: Icon(
                          isPlaying
                              ? Icons.equalizer_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                ],
              )
            : _buildDefaultThumbnail(
                music,
                isCurrentlyPlaying,
                isPlaying,
                isTablet,
              ),
      ),
    );
  }

  Widget _buildDefaultThumbnail(
    MediaItem music,
    bool isCurrentlyPlaying,
    bool isPlaying,
    bool isTablet,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              music.title.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isCurrentlyPlaying)
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              child: Center(
                child: Icon(
                  isPlaying ? Icons.equalizer_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF282828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _downloadMusic(MediaItem music) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF282828),
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
                  color: const Color(0xFF1DB954).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1DB954),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Downloading',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                music.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
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
                  color: const Color(0xFF1DB954),
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
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      music.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
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
          backgroundColor: const Color(0xFF282828),
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
}
