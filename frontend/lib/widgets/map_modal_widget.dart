import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class MapModal extends StatefulWidget {
  final VoidCallback? onClose;

  const MapModal({Key? key, this.onClose}) : super(key: key);

  @override
  _MapModalState createState() => _MapModalState();
}

class _MapModalState extends State<MapModal> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  final MapController _mapController = MapController();

  // Mock data untuk simulasi pergerakan mobil
  List<LatLng> routePoints = [
    LatLng(-6.2088, 106.8456), // Jakarta
    LatLng(-6.2090, 106.8460),
    LatLng(-6.2092, 106.8465),
    LatLng(-6.2095, 106.8470),
    LatLng(-6.2098, 106.8475),
  ];

  int currentRouteIndex = 0;
  Timer? _carMovementTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _startCarMovement();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _carMovementTimer?.cancel();
    super.dispose();
  }

  void _startCarMovement() {
    _carMovementTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          currentRouteIndex = (currentRouteIndex + 1) % routePoints.length;
        });

        // Animate map to follow car
        _mapController.move(
          routePoints[currentRouteIndex],
          _mapController.zoom,
        );
      }
    });
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.7 * _fadeInAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF00B14F), // Grab Green
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.navigation, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Live Navigation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _closeModal,
                              icon: Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Map Content
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: routePoints[currentRouteIndex],
                              zoom: 16.0,
                              maxZoom: 19.0,
                              minZoom: 10.0,
                            ),
                            nonRotatedChildren: [
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                            ],
                            children: [
                              // Tile Layer
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.maxg.entertainment',
                                maxZoom: 19,
                              ),

                              // Route Polyline
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: routePoints,
                                    strokeWidth: 4.0,
                                    color: Color(0xFF00B14F),
                                    isDotted: true,
                                  ),
                                ],
                              ),

                              // Markers Layer
                              MarkerLayer(
                                markers: [
                                  // Car Marker
                                  Marker(
                                    point: routePoints[currentRouteIndex],
                                    width: 40,
                                    height: 40,
                                    builder: (context) => Container(
                                      child: Image.asset(
                                        'assets/images/icons/car_marker.png', // Your custom car image
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Fallback icon jika gambar tidak ditemukan
                                          return Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF00B14F),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.directions_car,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Start Point
                                  Marker(
                                    point: routePoints.first,
                                    width: 30,
                                    height: 30,
                                    builder: (context) => Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  // End Point
                                  Marker(
                                    point: routePoints.last,
                                    width: 30,
                                    height: 30,
                                    builder: (context) => Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.flag,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Info Panel
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Live indicator
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF00B14F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vehicle moving to destination • ETA: 15 mins',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // Map controls
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _mapController.move(
                                      _mapController.center,
                                      _mapController.zoom + 1,
                                    );
                                  },
                                  icon: Icon(Icons.zoom_in),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {
                                    _mapController.move(
                                      _mapController.center,
                                      _mapController.zoom - 1,
                                    );
                                  },
                                  icon: Icon(Icons.zoom_out),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.grey[700],
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }
}
