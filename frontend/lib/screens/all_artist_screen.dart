// lib/screens/all_artists_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../screens/artist_detail_screen.dart';

class AllArtistsScreen extends StatefulWidget {
  final List<MediaItem> musicList;

  const AllArtistsScreen({super.key, required this.musicList});

  @override
  State<AllArtistsScreen> createState() => _AllArtistsScreenState();
}

class _AllArtistsScreenState extends State<AllArtistsScreen>
    with TickerProviderStateMixin {
  List<String> _artists = [];
  List<String> _filteredArtists = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  int _itemsPerPage = 24;
  int _currentPage = 1;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _loadArtists();
    _searchController.addListener(_filterArtists);
    _scrollController.addListener(_onScroll);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadArtists() {
    final uniqueArtists = widget.musicList
        .where((music) => music.artist != null && music.artist!.isNotEmpty)
        .map((music) => music.artist!)
        .toSet()
        .toList();

    uniqueArtists.sort();

    setState(() {
      _artists = uniqueArtists;
      _filteredArtists = uniqueArtists;
    });
  }

  void _filterArtists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArtists = _artists
          .where((artist) => artist.toLowerCase().contains(query))
          .toList();
      _currentPage = 1; // Reset to first page when searching
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 400 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
      _fabAnimationController.forward();
    } else if (_scrollController.offset <= 400 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
      _fabAnimationController.reverse();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  List<String> get _paginatedArtists {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredArtists.sublist(
      startIndex,
      endIndex > _filteredArtists.length ? _filteredArtists.length : endIndex,
    );
  }

  int get _totalPages => (_filteredArtists.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with Header
          SliverAppBar(
            backgroundColor: const Color(0xFF121212),
            expandedHeight: 280,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(isTablet)),
          ),

          // Search and Filter Section
          SliverPersistentHeader(
            pinned: false,
            delegate: _SliverSearchDelegate(
              searchController: _searchController,
              itemsPerPage: _itemsPerPage,
              onItemsPerPageChanged: (value) {
                setState(() {
                  _itemsPerPage = value;
                  _currentPage = 1;
                });
              },
              isTablet: isTablet,
            ),
          ),

          // Artists Grid
          _filteredArtists.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildArtistsGrid(isTablet),
                      if (_totalPages > 1) _buildPagination(),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimationController.value,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFF1DB954),
              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1DB954).withOpacity(0.3),
            const Color(0xFF121212),
            const Color(0xFF1DB954).withOpacity(0.1),
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: isTablet ? 32 : 24,
          right: isTablet ? 32 : 24,
          bottom: 24,
          top: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  width: isTablet ? 80 : 64,
                  height: isTablet ? 80 : 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: isTablet ? 40 : 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Artists',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 48 : 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jelajahi daftar artis ternama dari playlist kamu!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: const Color(0xFF1DB954),
                  size: isTablet ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistsGrid(bool isTablet) {
    final crossAxisCount = _getCrossAxisCount(
      MediaQuery.of(context).size.width,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 24,
        vertical: 24,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.85,
          crossAxisSpacing: isTablet ? 20 : 16,
          mainAxisSpacing: isTablet ? 24 : 20,
        ),
        itemCount: _paginatedArtists.length,
        itemBuilder: (context, index) {
          final artist = _paginatedArtists[index];
          final artistSongs = widget.musicList
              .where((music) => music.artist == artist)
              .toList();
          final artistSong = artistSongs.first;

          return _buildArtistCard(artist, artistSong, artistSongs, isTablet);
        },
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 6;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  Widget _buildArtistCard(
    String artist,
    MediaItem artistSong,
    List<MediaItem> artistSongs,
    bool isTablet,
  ) {
    return Hero(
      tag: 'artist_$artist',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ArtistDetailScreen(
                      artistName: artist,
                      musicList: artistSongs,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      );
                    },
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Artist Image with Play Button
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child:
                              artistSong.thumbnail != null &&
                                  artistSong.thumbnail!.isNotEmpty
                              ? _buildThumbnailImage(
                                  artistSong.thumbnail!,
                                  isTablet,
                                )
                              : _buildArtistPlaceholder(artist, isTablet),
                        ),
                      ),
                      // Play Button Overlay
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: isTablet ? 44 : 40,
                          height: isTablet ? 44 : 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1DB954).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Artist Info
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        artist,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${artistSongs.length} song${artistSongs.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: const Color(0xFF1DB954),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(String thumbnailPath, bool isTablet) {
    // Cek apakah local file atau network URL
    if (thumbnailPath.startsWith('/')) {
      // Local file
      return Image.file(
        File(thumbnailPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildArtistPlaceholder("A", isTablet),
      );
    } else {
      // Network URL
      return Image.network(
        thumbnailPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildArtistPlaceholder("A", isTablet),
      );
    }
  }

  Widget _buildArtistPlaceholder(String artist, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
        ),
      ),
      child: Center(
        child: Text(
          artist.isNotEmpty ? artist[0].toUpperCase() : 'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.person_search,
              color: Colors.white.withOpacity(0.5),
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _searchController.text.isEmpty
                ? 'No artists found'
                : 'No artists match your search',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchController.text.isEmpty
                ? 'Add some music to see artists'
                : 'Try searching for a different artist',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Button
              IconButton(
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPage > 1
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  foregroundColor: _currentPage > 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),

              const SizedBox(width: 16),

              // Page Numbers
              ...List.generate(_totalPages > 5 ? 5 : _totalPages, (index) {
                int pageNumber;
                if (_totalPages <= 5) {
                  pageNumber = index + 1;
                } else {
                  if (_currentPage <= 3) {
                    pageNumber = index + 1;
                  } else if (_currentPage >= _totalPages - 2) {
                    pageNumber = _totalPages - 4 + index;
                  } else {
                    pageNumber = _currentPage - 2 + index;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _currentPage = pageNumber),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: pageNumber == _currentPage
                            ? const Color(0xFF1DB954)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: pageNumber == _currentPage
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 16),

              // Next Button
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPage < _totalPages
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  foregroundColor: _currentPage < _totalPages
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Page Jump
          if (_totalPages > 10)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Jump to page: ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _currentPage,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _currentPage = value);
                        }
                      },
                      dropdownColor: const Color(0xFF282828),
                      style: const TextStyle(color: Colors.white),
                      items: List.generate(_totalPages, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text((index + 1).toString()),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final int itemsPerPage;
  final Function(int) onItemsPerPageChanged;
  final bool isTablet;

  _SliverSearchDelegate({
    required this.searchController,
    required this.itemsPerPage,
    required this.onItemsPerPageChanged,
    required this.isTablet,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF121212),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 24,
        vertical: 20,
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search artists...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Items per page selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: itemsPerPage,
                onChanged: (value) {
                  if (value != null) onItemsPerPageChanged(value);
                },
                dropdownColor: const Color(0xFF282828),
                style: const TextStyle(color: Colors.white),
                items: [24, 48, 96].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 88;

  @override
  double get minExtent => 88;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
