class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String brand;
  final int stock;
  final double discountPercentage;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.images = const [],
    required this.rating,
    required this.reviewCount,
    this.brand = '',
    required this.stock,
    this.discountPercentage = 0.0,
    this.isFavorite = false,
  });

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    List<String>? images,
    double? rating,
    int? reviewCount,
    String? brand,
    int? stock,
    double? discountPercentage,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      brand: brand ?? this.brand,
      stock: stock ?? this.stock,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, title: $title, price: $price}';
  }
}
