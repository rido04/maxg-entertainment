// lib/screens/all_artists_screen.dart - Updated with Blade template styling
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
      _currentPage = 1;
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/Background_Color.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 200,
              floating: false,
              pinned: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.grey[200]),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(isTablet),
              ),
            ),

            // Search and Filter Section
            SliverPersistentHeader(
              pinned: true,
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
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimationController.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.2),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: isTablet ? 32 : 24,
            right: isTablet ? 32 : 24,
            bottom: 24,
            top: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: isTablet ? 64 : 56,
                    height: isTablet ? 64 : 56,
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: isTablet ? 60 : 56,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Artists',
                          style: TextStyle(
                            foreground: Paint()
                              ..shader =
                                  const LinearGradient(
                                    colors: [Colors.white, Colors.white],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                            fontSize: isTablet ? 40 : 32,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Discover and explore our amazing collection of talented artists. From rising stars to established legends.',
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.grey[200],
                    size: isTablet ? 18 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          childAspectRatio: 0.9,
          crossAxisSpacing: isTablet ? 16 : 12,
          mainAxisSpacing: isTablet ? 20 : 16,
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
    if (screenWidth > 1536) return 8;
    if (screenWidth > 1280) return 6;
    if (screenWidth > 1024) return 5;
    if (screenWidth > 768) return 4;
    if (screenWidth > 640) return 3;
    return 2;
  }

  Widget _buildArtistCard(
    String artist,
    MediaItem artistSong,
    List<MediaItem> artistSongs,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ArtistDetailScreen(artistName: artist, musicList: artistSongs),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Artist Image with Play Button
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.3),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Artist Name
            Text(
              artist.length > 16 ? '${artist.substring(0, 16)}...' : artist,
              style: TextStyle(
                color: Colors.grey[200],
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(String thumbnailPath, bool isTablet) {
    if (thumbnailPath.startsWith('/')) {
      return Image.file(
        File(thumbnailPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildArtistPlaceholder("A", isTablet),
      );
    } else {
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
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.grey[200],
          size: isTablet ? 48 : 40,
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
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Icon(Icons.person_search, color: Colors.grey[400], size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty
                ? 'No artists found'
                : 'No artists match your search',
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'No artists available at the moment.'
                : 'No artists match your search "${_searchController.text}". Try a different search term.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white.withOpacity(0.3),
                  foregroundColor: _currentPage > 1
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF6B7280),
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
                            ? const Color(0xFF3B82F6)
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: pageNumber == _currentPage
                                ? Colors.white
                                : const Color(0xFF1F2937),
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
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white.withOpacity(0.3),
                  foregroundColor: _currentPage < _totalPages
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF6B7280),
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
                  style: TextStyle(color: Colors.grey[200], fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _currentPage,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _currentPage = value);
                        }
                      },
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF1F2937)),
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
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Color(0xFF1F2937)),
                decoration: InputDecoration(
                  hintText: 'Search artists...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Items per page selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: itemsPerPage,
                onChanged: (value) {
                  if (value != null) onItemsPerPageChanged(value);
                },
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
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
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
