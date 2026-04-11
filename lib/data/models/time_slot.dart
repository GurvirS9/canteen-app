import 'package:flutter/material.dart';

enum OccupancyStatus { available, fillingFast, full, closed }

extension OccupancyStatusExtension on OccupancyStatus {
  String get label {
    switch (this) {
      case OccupancyStatus.available:
        return 'Available';
      case OccupancyStatus.fillingFast:
        return 'Filling Fast';
      case OccupancyStatus.full:
        return 'Full';
      case OccupancyStatus.closed:
        return 'Closed';
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
      case OccupancyStatus.closed:
        return Colors.grey;
    }
  }
}

class TimeSlot {
  final String? id;
  final DateTime startTime;
  final DateTime endTime;
  final OccupancyStatus occupancy;
  final String? shopId;

  TimeSlot({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.occupancy,
    this.shopId,
  });

  bool get isAvailable => occupancy == OccupancyStatus.available || occupancy == OccupancyStatus.fillingFast;

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

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    final occupancyStr = (json['occupancy'] ?? json['status'] ?? 'available') as String;
    OccupancyStatus occupancy;
    switch (occupancyStr.toLowerCase()) {
      case 'fillingfast':
      case 'filling_fast':
        occupancy = OccupancyStatus.fillingFast;
        break;
      case 'full':
        occupancy = OccupancyStatus.full;
        break;
      case 'closed':
        occupancy = OccupancyStatus.closed;
        break;
      default:
        occupancy = OccupancyStatus.available;
    }

    return TimeSlot(
      id: (json['_id'] ?? json['id'])?.toString(),
      startTime: _parseTime(json['startTime'] as String),
      endTime: _parseTime(json['endTime'] as String),
      occupancy: occupancy,
      shopId: (json['shopId'] is String) ? json['shopId'] as String : (json['shopId'] is Map ? (json['shopId']['_id'] ?? json['shopId']['id'])?.toString() : null),
    );
  }

  /// Parses a time string that may be either a full ISO 8601 datetime
  /// (e.g. "2026-03-28T12:00:00") or a plain HH:mm time (e.g. "12:00").
  static DateTime _parseTime(String value) {
    // Plain time format: "HH:mm" or "H:mm"
    final timeOnly = RegExp(r'^\d{1,2}:\d{2}$');
    if (timeOnly.hasMatch(value)) {
      final parts = value.split(':');
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]));
    }
    return DateTime.parse(value);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'occupancy': occupancy.name,
        if (shopId != null) 'shopId': shopId,
      };
}
