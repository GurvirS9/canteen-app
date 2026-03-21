import 'package:flutter/material.dart';

enum OccupancyStatus { available, fillingFast, full }

extension OccupancyStatusExtension on OccupancyStatus {
  String get label {
    switch (this) {
      case OccupancyStatus.available:
        return 'Available';
      case OccupancyStatus.fillingFast:
        return 'Filling Fast';
      case OccupancyStatus.full:
        return 'Full';
    }
  }

  Color get color {
    switch (this) {
      case OccupancyStatus.available:
        return Colors.green;
      case OccupancyStatus.fillingFast:
        return Colors.orange;
      case OccupancyStatus.full:
        return Colors.red;
    }
  }
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final OccupancyStatus occupancy;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.occupancy,
  });

  bool get isAvailable => occupancy != OccupancyStatus.full;

  String get label {
    final startStr = _formatTime(startTime);
    final endStr = _formatTime(endTime);
    return '$startStr - $endStr';
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }
}
