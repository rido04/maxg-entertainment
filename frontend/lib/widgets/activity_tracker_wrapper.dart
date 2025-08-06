// lib/widgets/activity_tracker_wrapper.dart
import 'package:flutter/material.dart';
import '../services/activity_tracker_service.dart';

/// Wrapper widget yang akan mendeteksi semua user activity
/// Gunakan ini untuk wrap screen yang perlu di-track
class ActivityTrackerWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;
  final bool enableTracking;

  const ActivityTrackerWrapper({
    Key? key,
    required this.child,
    required this.screenName,
    this.enableTracking = true,
  }) : super(key: key);

  @override
  State<ActivityTrackerWrapper> createState() => _ActivityTrackerWrapperState();
}

class _ActivityTrackerWrapperState extends State<ActivityTrackerWrapper>
    with WidgetsBindingObserver {
  final ActivityTrackerService _activityTracker =
      ActivityTrackerService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set current screen name
    if (widget.enableTracking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _activityTracker.setCurrentScreen(widget.screenName);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableTracking) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _activityTracker.resumeTracking(reason: 'App resumed');
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _activityTracker.pauseTracking(reason: 'App paused/inactive');
        break;
      default:
        break;
    }
  }

  void _onUserActivity() {
    if (widget.enableTracking) {
      _activityTracker.onUserActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableTracking) {
      return widget.child;
    }

    return Listener(
      // Mendeteksi semua jenis input
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      onPointerUp: (_) => _onUserActivity(),
      child: GestureDetector(
        // Mendeteksi gesture
        onTap: _onUserActivity,
        onPanStart: (_) => _onUserActivity(),
        onPanUpdate: (_) => _onUserActivity(),
        onScaleStart: (_) => _onUserActivity(),
        onScaleUpdate: (_) => _onUserActivity(),
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}
