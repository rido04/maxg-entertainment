import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../routes/app_routes.dart';

class SlideNavigation extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const SlideNavigation({
    Key? key,
    required this.currentRoute,
    required this.onNavigate,
  }) : super(key: key);

  @override
  _SlideNavigationState createState() => _SlideNavigationState();
}

class _SlideNavigationState extends State<SlideNavigation>
    with TickerProviderStateMixin {
  bool isMenuOpen = false;
  late AnimationController _toggleController;
  late AnimationController _menuController;
  late Animation<double> _toggleRotation;
  late Animation<Offset> _menuSlideAnimation;
  late Animation<double> _menuOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controllers
    _toggleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _menuController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Toggle button rotation animation
    _toggleRotation =
        Tween<double>(
          begin: 0,
          end: 0.5, // 180 degrees
        ).animate(
          CurvedAnimation(parent: _toggleController, curve: Curves.easeInOut),
        );

    // Menu slide animation
    _menuSlideAnimation =
        Tween<Offset>(
          begin: Offset(1.0, 0), // Start from right
          end: Offset(0, 0), // End at center
        ).animate(
          CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
        );

    // Menu opacity animation
    _menuOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });

    if (isMenuOpen) {
      _toggleController.forward();
      _menuController.forward();
    } else {
      _toggleController.reverse();
      _menuController.reverse();
    }
  }

  Widget _buildIcon(String iconName) {
    switch (iconName) {
      case 'home':
        return Icon(Icons.home, size: 20);
      case 'movies':
        return Icon(Icons.movie, size: 20);
      case 'music':
        return Icon(Icons.music_note, size: 20);
      case 'games':
        return Icon(Icons.games, size: 20);
      case 'news':
        return Icon(Icons.newspaper, size: 20);
      case 'info':
        return Icon(Icons.info, size: 20);
      default:
        return Icon(Icons.circle, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Toggle Button (seperti navToggle di blade)
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height / 2 - 24,
          child: AnimatedBuilder(
            animation: _toggleRotation,
            builder: (context, child) {
              return GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: RotationTransition(
                    turns: _toggleRotation,
                    child: Icon(
                      isMenuOpen ? Icons.close : Icons.chevron_left,
                      color: Color(0xFF94a3b8), // slate-400
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Navigation Menu (seperti navigationMenu di blade)
        Positioned(
          right: 16,
          top:
              MediaQuery.of(context).size.height / 2 -
              (AppRoutes.menuItems.length * 28),
          child: SlideTransition(
            position: _menuSlideAnimation,
            child: FadeTransition(
              opacity: _menuOpacityAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: AppRoutes.menuItems.map((item) {
                    final isActive = widget.currentRoute == item.route;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.onNavigate(item.route);
                            _toggleMenu(); // Close menu after navigation
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Color(0xFF22c55e).withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // Icon
                                Center(child: _buildIcon(item.icon)),

                                // Tooltip (seperti tooltip di blade)
                                Positioned(
                                  right: 60,
                                  top: 12,
                                  child: AnimatedOpacity(
                                    opacity:
                                        0.0, // Always hidden, shows on hover in web
                                    duration: Duration(milliseconds: 200),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1e293b), // slate-800
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
