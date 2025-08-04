// lib/screens/universal_game_screen.dart - Updated version
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/game_item.dart';
import '../games/flames/endless_runner_screen.dart';

class UniversalGamePlayerScreen extends StatefulWidget {
  final GameItem gameItem;

  const UniversalGamePlayerScreen({Key? key, required this.gameItem})
    : super(key: key);

  @override
  _UniversalGamePlayerScreenState createState() =>
      _UniversalGamePlayerScreenState();
}

class _UniversalGamePlayerScreenState extends State<UniversalGamePlayerScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    print('🎮 Initializing game: ${widget.gameItem.name}');
    print('🎯 Game type: ${widget.gameItem.gameType}');
    print('🏷️ Game class: ${widget.gameItem.gameClass}');

    if (widget.gameItem.gameType == GameType.webview) {
      _initializeWebView();
    } else if (widget.gameItem.gameType == GameType.flame) {
      // Flame games load immediately
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeWebView() {
    if (widget.gameItem.url == null) {
      setState(() {
        _error = 'Game URL not available';
        _isLoading = false;
      });
      return;
    }

    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              print('🔄 WebView loading progress: $progress%');
            },
            onPageStarted: (String url) {
              print('🌐 WebView started loading: $url');
              setState(() {
                _isLoading = true;
                _error = null;
              });
            },
            onPageFinished: (String url) {
              print('✅ WebView finished loading: $url');
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              print('❌ WebView error: ${error.description}');
              setState(() {
                _error = 'Failed to load game: ${error.description}';
                _isLoading = false;
              });
            },
          ),
        );

      // Load the game URL
      if (widget.gameItem.url!.startsWith('assets/')) {
        // Local asset
        final assetPath =
            'assets/${widget.gameItem.url!.replaceFirst('assets/', '')}';
        _webViewController!.loadFlutterAsset(assetPath);
      } else {
        // Remote URL
        _webViewController!.loadRequest(Uri.parse(widget.gameItem.url!));
      }
    } catch (e) {
      print('❌ WebView initialization error: $e');
      setState(() {
        _error = 'Failed to initialize game: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildFlameGame() {
    // Handle Flame games based on gameClass
    if (widget.gameItem.gameClass == null) {
      return _buildError('Flame game class not specified');
    }

    switch (widget.gameItem.gameClass.toString()) {
      case 'GameClass.endlessRunner':
        return EndlessRunnerScreen();
      default:
        return _buildError(
          'Unknown Flame game class: ${widget.gameItem.gameClass}',
        );
    }
  }

  Widget _buildWebViewGame() {
    if (_webViewController == null) {
      return _buildError('WebView not initialized');
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController!),
        if (_isLoading)
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading ${widget.gameItem.name}...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWidgetGame() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Widget Game',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon!',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    if (_error != null) {
      return _buildError(_error!);
    }

    switch (widget.gameItem.gameType) {
      case GameType.flame:
        return _buildFlameGame();
      case GameType.webview:
        return _buildWebViewGame();
      case GameType.widget:
        return _buildWidgetGame();
      default:
        return _buildError('Unknown game type: ${widget.gameItem.gameType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Game content
            _buildGameContent(),

            // Header with back button and game info (only for WebView games)
            if (widget.gameItem.gameType == GameType.webview)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.gameItem.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.gameItem.gameType
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh button for WebView games
                      if (widget.gameItem.gameType == GameType.webview &&
                          _webViewController != null)
                        IconButton(
                          onPressed: () => _webViewController!.reload(),
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
