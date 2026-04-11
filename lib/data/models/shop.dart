/// Shop model – matches the `ShopMapView` projection returned by `GET /api/shops`.
class Shop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int seatingCapacity;
  final int tableCount;
  final double rating;
  final int currentQueue;
  final String queueLevel; // "low" | "medium" | "high"
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final bool isCurrentlyOpen;

  const Shop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.seatingCapacity,
    required this.tableCount,
    required this.rating,
    required this.currentQueue,
    required this.queueLevel,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
    required this.isCurrentlyOpen,
  });

  /// Human-readable queue badge colour
  String get queueEmoji {
    switch (queueLevel.toLowerCase()) {
      case 'low':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'high':
        return '🔴';
      default:
        return '⚪';
    }
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    // Coordinates may be nested as { type, coordinates } or flat lat/lng
    double lat = 0.0;
    double lng = 0.0;
    final loc = json['location'];
    if (loc is Map) {
      final coords = loc['coordinates'] as List?;
      if (coords != null && coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    } else {
      lat = (json['latitude'] as num? ?? 0).toDouble();
      lng = (json['longitude'] as num? ?? 0).toDouble();
    }

    return Shop(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      address: json['address'] as String? ?? '',
      seatingCapacity: (json['seatingCapacity'] as num?)?.toInt() ?? 0,
      tableCount: (json['tableCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      currentQueue: (json['currentQueue'] as num?)?.toInt() ?? 0,
      queueLevel: json['queueLevel'] as String? ?? 'low',
      openingTime: json['openingTime'] as String? ?? '',
      closingTime: json['closingTime'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      isCurrentlyOpen: json['isCurrentlyOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'seatingCapacity': seatingCapacity,
        'tableCount': tableCount,
        'rating': rating,
        'currentQueue': currentQueue,
        'queueLevel': queueLevel,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'isOpen': isOpen,
        'isCurrentlyOpen': isCurrentlyOpen,
      };
}
