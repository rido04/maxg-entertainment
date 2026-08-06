// lib/widgets/running_text_widget.dart
// Alternative version using AnimationController (smoother)

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/running_text_item.dart';

class RunningTextWidget extends StatefulWidget {
  final List<RunningTextItem> runningTexts;
  final bool isTop;

  const RunningTextWidget({
    Key? key,
    required this.runningTexts,
    required this.isTop,
  }) : super(key: key);

  @override
  State<RunningTextWidget> createState() => _RunningTextWidgetState();
}

class _RunningTextWidgetState extends State<RunningTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _rotationTimer;
  int _currentIndex = 0;
  RunningTextItem? _currentText;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Will be updated based on speed
    );

    _updateCurrentText();

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _startScrolling();
        _startRotation();
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RunningTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.runningTexts != widget.runningTexts) {
      print('📝 Running texts updated in widget - restarting');
      _currentIndex = 0;
      _updateCurrentText();

      // RESTART animation dan rotation setelah update
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _startScrolling();
          _startRotation();
        }
      });
    }
  }

  void _updateCurrentText() {
    final filteredTexts = widget.runningTexts
        .where((rt) => widget.isTop ? rt.isTop : rt.isBottom)
        .toList();

    if (filteredTexts.isEmpty) {
      setState(() => _currentText = null);
      return;
    }

    if (_currentIndex >= filteredTexts.length) {
      _currentIndex = 0;
    }

    setState(() {
      _currentText = filteredTexts[_currentIndex];
    });

    print(
      '🔄 Switched to running text: ${_currentText?.text.substring(0, _currentText!.text.length > 30 ? 30 : _currentText!.text.length)}...',
    );
  }

  void _startScrolling() {
    if (_currentText == null || !mounted) return;

    _animationController.stop();
    _animationController.reset();

    final estimatedWidth =
        _currentText!.text.length * _currentText!.fontSize * 0.6;
    final speed = _currentText!.speed;
    final duration = (estimatedWidth / speed).ceil();

    _animationController.duration = Duration(seconds: duration.clamp(5, 60));

    print(
      '▶️ Starting scroll animation (speed: ${speed}px/s, duration: ${duration}s)',
    );

    _animationController.repeat();

    // Tambahkan listener untuk ensure terus running
    if (!_animationController.isAnimating) {
      print('⚠️ Animation not running, forcing restart');
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) _animationController.repeat();
      });
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();

    if (_currentText == null || !mounted) return;

    final displayDuration = _currentText!.displayDuration;

    print('🔄 Starting rotation (duration: ${displayDuration}s)');

    // Gunakan Timer (bukan periodic) dan recursive
    _rotationTimer = Timer(Duration(seconds: displayDuration), () {
      if (!mounted) return;

      final filteredTexts = widget.runningTexts
          .where((rt) => widget.isTop ? rt.isTop : rt.isBottom)
          .toList();

      if (filteredTexts.length <= 1) {
        _startRotation(); // Restart timer meski cuma 1 text
        return;
      }

      _currentIndex = (_currentIndex + 1) % filteredTexts.length;
      _updateCurrentText();
      _startScrolling(); // PENTING: Call ini
      _startRotation(); // Recursive restart
    });
  }

  void _resetAnimation() {
    _animationController.stop();
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentText == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 50,
      color: _currentText!.backgroundColorValue,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final textWidth =
                    _currentText!.text.length * _currentText!.fontSize * 0.6;
                final totalWidth = textWidth + 100; // Text + spacer

                // Calculate offset for smooth loop
                final offset =
                    _animationController.value *
                    (totalWidth + constraints.maxWidth);
                if (offset > 10000) {
                  print(
                    '⚠️ OFFSET TOO LARGE: $offset (controller: ${_animationController.value})',
                  );
                }
                return Transform.translate(
                  offset: Offset(-offset, 0),
                  child: Row(
                    children: [
                      SizedBox(width: constraints.maxWidth),
                      _buildText(),
                      SizedBox(width: constraints.maxWidth),
                      _buildText(),
                      SizedBox(width: constraints.maxWidth),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _currentText!.text,
        style: TextStyle(
          color: _currentText!.textColorValue,
          fontSize: _currentText!.fontSize.toDouble(),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
