// lib/screens/universal_game_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/game_item.dart';
import '../games/flames/snake_game.dart';
import '../games/flames/tictactoe_game.dart';

class UniversalGamePlayerScreen extends StatefulWidget {
  final GameItem gameItem;

  const UniversalGamePlayerScreen({super.key, required this.gameItem});

  @override
  State<UniversalGamePlayerScreen> createState() =>
      _UniversalGamePlayerScreenState();
}

class _UniversalGamePlayerScreenState extends State<UniversalGamePlayerScreen> {
  late Widget gameWidget;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      switch (widget.gameItem.gameType) {
        case GameType.flame:
          gameWidget = _buildFlameGame();
          break;
        case GameType.webview:
          gameWidget = _buildWebViewGame();
          break;
        case GameType.widget:
          gameWidget = _buildWidgetGame();
          break;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to initialize game: $e';
      });
    }
  }

  Widget _buildFlameGame() {
    final gameClass = widget.gameItem.gameClass;

    Game? game;
    switch (gameClass) {
      case 'SnakeGame':
        game = SnakeGame();
        break;
      case 'TicTacToeGame':
        game = TicTacToeGame();
        break;
      default:
        throw Exception('Unknown Flame game class: $gameClass');
    }

    return GameWidget<Game>(game: game);
  }

  Widget _buildWebViewGame() {
    return WebViewGameWidget(
      gameUrl: widget.gameItem.url!,
      gameName: widget.gameItem.name,
    );
  }

  Widget _buildWidgetGame() {
    // For pure Flutter widget games
    throw Exception('Widget games not implemented yet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.gameItem.icon, style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.gameItem.name,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (widget.gameItem.gameType == GameType.flame)
            IconButton(
              onPressed: _showFlameGameMenu,
              icon: Icon(Icons.more_vert),
              tooltip: 'Game Menu',
            )
          else if (widget.gameItem.gameType == GameType.webview)
            IconButton(
              onPressed: _showWebViewGameMenu,
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
              'Loading ${widget.gameItem.name}...',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              widget.gameItem.gameType == GameType.flame
                  ? 'Native Flame Game'
                  : 'WebView Game',
              style: TextStyle(color: Colors.grey, fontSize: 12),
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
                    onPressed: _initializeGame,
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

    return gameWidget;
  }

  void _showFlameGameMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Flame Game Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.restart_alt, color: Colors.white),
              title: Text(
                'Restart Game',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _initializeGame();
              },
            ),
            ListTile(
              leading: Icon(Icons.fullscreen, color: Colors.white),
              title: Text('Fullscreen', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text('Game Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showGameInfo();
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

  void _showWebViewGameMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WebView Game Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.refresh, color: Colors.white),
              title: Text('Reload Game', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Reload WebView
                _initializeGame();
              },
            ),
            ListTile(
              leading: Icon(Icons.fullscreen, color: Colors.white),
              title: Text('Fullscreen', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
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

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Text(widget.gameItem.icon, style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.gameItem.name,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.gameItem.description,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              'Type',
              widget.gameItem.gameType == GameType.flame
                  ? 'Native Flame Game'
                  : 'HTML5 WebView Game',
            ),
            _buildInfoRow('Status', widget.gameItem.status.toUpperCase()),
            _buildInfoRow(
              'Offline Support',
              widget.gameItem.offline ? 'Yes' : 'No',
            ),
            if (widget.gameItem.gameClass != null)
              _buildInfoRow('Game Class', widget.gameItem.gameClass!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
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

// Separate WebView widget for better separation
class WebViewGameWidget extends StatefulWidget {
  final String gameUrl;
  final String gameName;

  const WebViewGameWidget({
    super.key,
    required this.gameUrl,
    required this.gameName,
  });

  @override
  State<WebViewGameWidget> createState() => _WebViewGameWidgetState();
}

class _WebViewGameWidgetState extends State<WebViewGameWidget> {
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
                'Failed to Load WebView Game',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                      _loadGame();
                    },
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

  void reload() {
    _controller.reload();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
