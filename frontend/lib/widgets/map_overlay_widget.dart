import 'package:flutter/material.dart';

// Import the widgets we created
import 'map_modal_widget.dart';
import 'map_trigger_button.dart';
import '../layouts/main_layouts.dart';

class MapOverlayWidget extends StatefulWidget {
  final Widget child; // The main content

  const MapOverlayWidget({Key? key, required this.child}) : super(key: key);

  @override
  _MapOverlayWidgetState createState() => _MapOverlayWidgetState();
}

class _MapOverlayWidgetState extends State<MapOverlayWidget> {
  bool _isMapModalVisible = false;

  void _showMapModal() {
    setState(() {
      _isMapModalVisible = true;
    });
  }

  void _hideMapModal() {
    setState(() {
      _isMapModalVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          widget.child,

          // Map trigger button (positioned at bottom center)
          MapTriggerButton(onTap: _showMapModal),

          // Map modal overlay
          if (_isMapModalVisible) MapModal(onClose: _hideMapModal),
        ],
      ),
    );
  }
}

// Usage example: Wrap your MainLayout with MapOverlayWidget
class MainLayoutWithMap extends StatelessWidget {
  final String? initialRoute;

  const MainLayoutWithMap({Key? key, this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapOverlayWidget(
      child: Column(
        children: [
          // Your existing MainLayout content
          Expanded(
            child: initialRoute != null
                ? MainLayout(initialRoute: initialRoute!)
                : MainLayout(),
          ),
          // Mini Player or other bottom content
          // const MiniPlayer(),
        ],
      ),
    );
  }
}
