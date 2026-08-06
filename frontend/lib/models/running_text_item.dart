// lib/models/running_text_item.dart

import 'package:flutter/material.dart';

class RunningTextItem {
  final int id;
  final String text;
  final String position; // 'top' or 'bottom'
  final int priority;
  final String backgroundColor;
  final String textColor;
  final int fontSize;
  final int speed; // pixels per second
  final int displayDuration; // seconds
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;

  RunningTextItem({
    required this.id,
    required this.text,
    required this.position,
    required this.priority,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.speed,
    required this.displayDuration,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  factory RunningTextItem.fromJson(Map<String, dynamic> json) {
    return RunningTextItem(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      position: json['position'] as String? ?? 'bottom',
      priority: json['priority'] as int? ?? 0,
      backgroundColor: json['background_color'] as String? ?? '#000000',
      textColor: json['text_color'] as String? ?? '#FFFFFF',
      fontSize: json['font_size'] as int? ?? 16,
      speed: json['speed'] as int? ?? 50,
      displayDuration: json['display_duration'] as int? ?? 30,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }

  // 👇 TAMBAH: toJson untuk Hive caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'position': position,
      'priority': priority,
      'background_color': backgroundColor,
      'text_color': textColor,
      'font_size': fontSize,
      'speed': speed,
      'display_duration': displayDuration,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  bool get isTop => position == 'top';
  bool get isBottom => position == 'bottom';

  Color get backgroundColorValue {
    try {
      // Support both hex (#000000) and rgba(0,0,0,0.5)
      if (backgroundColor.startsWith('#')) {
        final hexColor = backgroundColor.replaceAll('#', '');
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      } else if (backgroundColor.startsWith('rgba')) {
        // Parse rgba(r, g, b, a)
        final rgbaValues = backgroundColor
            .replaceAll('rgba(', '')
            .replaceAll(')', '')
            .split(',')
            .map((e) => e.trim())
            .toList();

        if (rgbaValues.length == 4) {
          final r = int.parse(rgbaValues[0]);
          final g = int.parse(rgbaValues[1]);
          final b = int.parse(rgbaValues[2]);
          final a = (double.parse(rgbaValues[3]) * 255).toInt();
          return Color.fromARGB(a, r, g, b);
        }
      }
    } catch (e) {
      print('⚠️ Failed to parse background color: $backgroundColor');
    }
    return Colors.black.withOpacity(0.7);
  }

  Color get textColorValue {
    try {
      if (textColor.startsWith('#')) {
        final hexColor = textColor.replaceAll('#', '');
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      }
    } catch (e) {
      print('⚠️ Failed to parse text color: $textColor');
    }
    return Colors.white;
  }

  @override
  String toString() {
    return 'RunningTextItem(id: $id, text: "$text", position: $position, priority: $priority)';
  }
}
