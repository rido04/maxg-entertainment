import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GamePlayerScreen extends StatefulWidget {
  final String gameUrl;
  final String gameName;

  const GamePlayerScreen({
    super.key,
    required this.gameUrl,
    this.gameName = 'Game',
  });

  @override
  State<GamePlayerScreen> createState() => _GamePlayerScreenState();
}

class _GamePlayerScreenState extends State<GamePlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = 'Failed to load game: ${error.description}';
            });
          },
        ),
      );

    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      if (widget.gameUrl.startsWith('assets/')) {
        // Load offline game from assets
        await _loadOfflineGame();
      } else {
        // Load online game from URL
        await _controller.loadRequest(Uri.parse(widget.gameUrl));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading game: $e';
      });
    }
  }

  Future<void> _loadOfflineGame() async {
    try {
      // Load HTML content from assets
      final htmlContent = await rootBundle.loadString(widget.gameUrl);

      // Modify HTML content to use local assets
      final modifiedHtml = _modifyHtmlForOffline(htmlContent);

      // Load HTML string into WebView
      await _controller.loadHtmlString(
        modifiedHtml,
        baseUrl: 'file:///android_asset/flutter_assets/',
      );
    } catch (e) {
      throw Exception('Failed to load offline game: $e');
    }
  }

  String _modifyHtmlForOffline(String htmlContent) {
    // Get the game directory path
    final gameDir = widget.gameUrl.substring(
      0,
      widget.gameUrl.lastIndexOf('/'),
    );

    // Replace relative paths with asset paths
    String modifiedHtml = htmlContent;

    // Replace CSS references
    modifiedHtml = modifiedHtml.replaceAllMapped(
      RegExp(r'href="([^"]*\.css)"'),
      (match) => 'href="flutter_assets/$gameDir/${match.group(1)}"',
    );

    // Replace JS references
    modifiedHtml = modifiedHtml.replaceAllMapped(
      RegExp(r'src="([^"]*\.js)"'),
      (match) => 'src="flutter_assets/$gameDir/${match.group(1)}"',
    );

    // Replace image references if any
    modifiedHtml = modifiedHtml.replaceAllMapped(
      RegExp(r'src="([^"]*\.(png|jpg|jpeg|gif|svg))"'),
      (match) => 'src="flutter_assets/$gameDir/${match.group(1)}"',
    );

    return modifiedHtml;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.gameName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _controller.reload(),
            icon: Icon(Icons.refresh),
            tooltip: 'Restart Game',
          ),
          IconButton(
            onPressed: () {
              // Toggle fullscreen or other game controls
              _showGameMenu();
            },
            icon: Icon(Icons.more_vert),
            tooltip: 'Game Menu',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading ${widget.gameName}...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Failed to Load Game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _loadGame(),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return WebViewWidget(controller: _controller);
  }

  void _showGameMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Game Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.refresh, color: Colors.white),
              title: Text(
                'Restart Game',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.reload();
              },
            ),
            ListTile(
              leading: Icon(Icons.fullscreen, color: Colors.white),
              title: Text('Fullscreen', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement fullscreen logic if needed
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text('Exit Game', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Restore system UI when leaving game
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
