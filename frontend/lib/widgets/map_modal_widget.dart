import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;

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

  // Car rotation animation controller
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  final MapController _mapController = MapController();

  // GPS and tracking variables
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  Position? _previousPosition;
  List<Position> _positionHistory = [];
  List<LatLng> _pathPoints = [];

  // Direction and movement tracking
  double _currentBearing = 0;
  double _previousBearing = 0;
  double _smoothedBearing = 0;
  double _currentSpeed = 0;
  String _currentDirection = 'straight';

  // GPS status
  bool _isGPSActive = false;
  String _gpsStatus = 'GPS: Tidak aktif';
  String _accuracyInfo = '';

  // Configuration constants
  static const int HISTORY_SIZE = 8;
  static const double MIN_DISTANCE = 3.0;
  static const double TURN_THRESHOLD = 15.0;
  static const double BEARING_SMOOTHING = 0.2;
  static const double MIN_SPEED_FOR_DIRECTION = 1.0;
  static const double SIGNIFICANT_TURN_THRESHOLD = 30.0;

  // Default position (Jakarta)
  final LatLng _defaultPosition = LatLng(-6.200000, 106.816666);

  @override
  void initState() {
    super.initState();

    // Modal animation controller
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

    // Car rotation animation controller
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  // Location permission and GPS methods
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _gpsStatus = 'GPS: Layanan lokasi tidak aktif';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _gpsStatus = 'GPS: Izin lokasi ditolak';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _gpsStatus = 'GPS: Izin lokasi ditolak permanen';
      });
      return;
    }

    // Auto start GPS if permission granted
    _startGPSTracking();
  }

  Future<void> _startGPSTracking() async {
    if (_isGPSActive) return;

    setState(() {
      _gpsStatus = 'GPS: Mengaktifkan...';
      _isGPSActive = true;
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update setiap 1 meter
    );

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_onLocationUpdate, onError: _onLocationError);
    } catch (e) {
      setState(() {
        _gpsStatus = 'GPS: Error - ${e.toString()}';
        _isGPSActive = false;
      });
    }
  }

  void _stopGPSTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    setState(() {
      _isGPSActive = false;
      _gpsStatus = 'GPS: Dimatikan';
      _currentSpeed = 0;
      _currentDirection = 'straight';
      _pathPoints.clear();
      _positionHistory.clear();
    });

    _resetTracking();
  }

  void _resetTracking() {
    _currentPosition = null;
    _previousPosition = null;
    _positionHistory.clear();
    _currentBearing = 0;
    _previousBearing = 0;
    _smoothedBearing = 0;
    _currentSpeed = 0;
    _currentDirection = 'straight';
  }

  void _onLocationUpdate(Position position) {
    if (!mounted) return;

    final accuracy = position.accuracy;

    // Filter out low accuracy readings
    if (accuracy > 50) {
      setState(() {
        _accuracyInfo = 'Akurasi rendah: ${accuracy.round()}m';
      });
      return;
    }

    setState(() {
      _gpsStatus = 'GPS: Aktif';
      _accuracyInfo = 'Akurasi: ${accuracy.round()}m';
    });

    _currentPosition = position;

    // Add to position history
    _positionHistory.add(position);
    if (_positionHistory.length > HISTORY_SIZE) {
      _positionHistory.removeAt(0);
    }

    // Add to path
    _pathPoints.add(LatLng(position.latitude, position.longitude));
    if (_pathPoints.length > 50) {
      _pathPoints.removeAt(0);
    }

    _updateMovementTracking();
    _updateMapPosition(position);
  }

  void _updateMovementTracking() {
    if (_previousPosition == null || _positionHistory.length < 3) {
      _previousPosition = _currentPosition;
      return;
    }

    final distance = Geolocator.distanceBetween(
      _previousPosition!.latitude,
      _previousPosition!.longitude,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    final timeDiff =
        (_currentPosition!.timestamp.millisecondsSinceEpoch -
            _previousPosition!.timestamp.millisecondsSinceEpoch) /
        1000.0;

    if (distance > MIN_DISTANCE && timeDiff > 0.5) {
      // Calculate speed (km/h)
      _currentSpeed = (distance / timeDiff) * 3.6;

      // Calculate bearing
      final newBearing = _calculateBearing(
        _previousPosition!.latitude,
        _previousPosition!.longitude,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Smooth bearing
      if (_currentBearing != 0) {
        _smoothedBearing = _smoothBearing(
          newBearing,
          _currentBearing,
          BEARING_SMOOTHING,
        );
      } else {
        _smoothedBearing = newBearing;
      }

      // Detect turn direction
      if (_previousBearing != 0) {
        _currentDirection = _detectTurnDirection(
          _smoothedBearing,
          _previousBearing,
          _currentSpeed,
        );
      }

      // Animate car rotation
      _animateCarRotation(_currentBearing, _smoothedBearing);

      _currentBearing = _smoothedBearing;
      _previousBearing = _smoothedBearing;
      _previousPosition = _currentPosition;
    }
  }

  double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    final dLng = (lng2 - lng1) * math.pi / 180;
    final lat1Rad = lat1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2Rad);
    final x =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLng);

    double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  double _smoothBearing(double newBearing, double oldBearing, double factor) {
    double diff = newBearing - oldBearing;

    // Handle bearing wrap-around
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    return (oldBearing + diff * factor + 360) % 360;
  }

  String _detectTurnDirection(
    double currentBearing,
    double previousBearing,
    double speed,
  ) {
    if (speed < MIN_SPEED_FOR_DIRECTION) {
      return 'straight';
    }

    double bearingDiff = currentBearing - previousBearing;

    // Handle bearing wrap-around
    if (bearingDiff > 180) bearingDiff -= 360;
    if (bearingDiff < -180) bearingDiff += 360;

    final absDiff = bearingDiff.abs();

    // Add hysteresis to prevent flickering
    if (_currentDirection != 'straight') {
      if (absDiff < TURN_THRESHOLD * 0.7) {
        return 'straight';
      }
    } else {
      if (absDiff < TURN_THRESHOLD * 1.3) {
        return 'straight';
      }
    }

    if (absDiff > SIGNIFICANT_TURN_THRESHOLD) {
      return bearingDiff > 0 ? 'right' : 'left';
    } else {
      return bearingDiff > 0 ? 'right' : 'left';
    }
  }

  void _animateCarRotation(double fromBearing, double toBearing) {
    _rotationAnimation = Tween<double>(begin: fromBearing, end: toBearing)
        .animate(
          CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
        );

    _rotationController.reset();
    _rotationController.forward();
  }

  void _updateMapPosition(Position position) {
    final latLng = LatLng(position.latitude, position.longitude);
    _mapController.move(latLng, _mapController.zoom);
  }

  void _onLocationError(dynamic error) {
    setState(() {
      _gpsStatus = 'GPS: Error - ${error.toString()}';
      _isGPSActive = false;
    });
  }

  void _toggleGPS() {
    if (_isGPSActive) {
      _stopGPSTracking();
    } else {
      _startGPSTracking();
    }
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  Widget _buildCarMarker() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        final rotation = _rotationAnimation.value;

        // Tentukan gambar berdasarkan arah
        String carImagePath;
        double carWidth, carHeight;

        switch (_currentDirection) {
          case 'left':
            carImagePath = 'assets/images/car/camry-turn-left.png';
            carWidth = 50;
            carHeight = 30;
            break;
          case 'right':
            carImagePath = 'assets/images/car/camry-turn-right.png';
            carWidth = 50;
            carHeight = 30;
            break;
          default:
            carImagePath = 'assets/images/car/camry-top.png';
            carWidth = 30;
            carHeight = 50;
        }

        return Container(
          width: carWidth,
          height: carHeight,
          child: Transform.rotate(
            angle: _currentDirection == 'straight'
                ? rotation * math.pi / 180
                : 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                carImagePath,
                width: carWidth,
                height: carHeight,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback ke icon jika gambar tidak ditemukan
                  return _buildFallbackCarIcon(rotation);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackCarIcon(double rotation) {
    IconData carIcon;
    Color carColor;

    switch (_currentDirection) {
      case 'left':
        carIcon = Icons.turn_left;
        carColor = Colors.orange;
        break;
      case 'right':
        carIcon = Icons.turn_right;
        carColor = Colors.orange;
        break;
      default:
        carIcon = Icons.navigation;
        carColor = Color(0xFF00B14F);
    }

    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: carColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(carIcon, color: Colors.white, size: 24),
      ),
    );
  }

  String _getDirectionText() {
    switch (_currentDirection) {
      case 'left':
        return 'Belok Kiri';
      case 'right':
        return 'Belok Kanan';
      default:
        return 'Lurus';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLatLng = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultPosition;

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
                          color: Color(0xFF00B14F),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Navigation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _gpsStatus,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                              center: currentLatLng,
                              zoom: 18.0,
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

                              // Path Polyline
                              if (_pathPoints.length > 1)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _pathPoints,
                                      strokeWidth: 3.0,
                                      color: Color(0xFF2196F3),
                                      isDotted: true,
                                    ),
                                  ],
                                ),

                              // Markers Layer
                              MarkerLayer(
                                markers: [
                                  // Car Marker
                                  Marker(
                                    point: currentLatLng,
                                    width: _currentDirection == 'straight'
                                        ? 30
                                        : 50,
                                    height: _currentDirection == 'straight'
                                        ? 50
                                        : 30,
                                    builder: (context) => _buildCarMarker(),
                                  ),

                                  // Start Point (if path exists)
                                  if (_pathPoints.isNotEmpty)
                                    Marker(
                                      point: _pathPoints.first,
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
                        child: Column(
                          children: [
                            // GPS and Direction Info
                            Row(
                              children: [
                                // Live indicator
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isGPSActive
                                        ? Color(0xFF00B14F)
                                        : Colors.grey,
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
                                        _isGPSActive ? 'LIVE' : 'OFF',
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Arah: ${_getDirectionText()} • ${_currentSpeed.toStringAsFixed(1)} km/h',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (_accuracyInfo.isNotEmpty)
                                        Text(
                                          _accuracyInfo,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            // Control buttons
                            Row(
                              children: [
                                // GPS toggle button
                                ElevatedButton.icon(
                                  onPressed: _toggleGPS,
                                  icon: Icon(
                                    _isGPSActive
                                        ? Icons.gps_off
                                        : Icons.gps_fixed,
                                  ),
                                  label: Text(
                                    _isGPSActive ? 'Stop GPS' : 'Start GPS',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isGPSActive
                                        ? Colors.red
                                        : Color(0xFF00B14F),
                                    foregroundColor: Colors.white,
                                  ),
                                ),

                                Spacer(),

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
