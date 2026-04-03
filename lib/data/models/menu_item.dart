class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isVeg;
  final bool isEgg;
  final bool isAvailable;
  final double rating;
  final int preparationTime; // minutes

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isVeg,
    this.isEgg = false,
    this.isAvailable = true,
    this.rating = 4.0,
    this.preparationTime = 10,
  });

  /// Maps from backend JSON keys:
  ///   name, price, prepTime, image
  /// Falls back to app-side keys when present (for demo/mock data).
  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] as String,
        description: (json['description'] as String?) ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: (json['image'] ?? json['imageUrl'] ?? '') as String,
        category: (json['category'] as String?) ?? 'Snacks',
        isVeg: json['isVeg'] as bool? ?? true,
        isEgg: json['isEgg'] as bool? ?? false,
        isAvailable: json['isAvailable'] as bool? ?? true,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
        preparationTime: json['prepTime'] as int? ??
            json['preparationTime'] as int? ??
            10,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': imageUrl,
        'category': category,
        'isVeg': isVeg,
        'isEgg': isEgg,
        'isAvailable': isAvailable,
        'rating': rating,
        'prepTime': preparationTime,
      };
}
