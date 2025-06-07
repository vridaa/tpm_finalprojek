class Product {
  final int? produkID;
  final String nama;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  late final bool isAddcart;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.produkID,
    required this.nama,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAddcart = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      produkID: json['produkID'] ?? json['id'],
      nama: json['nama'] as String,
      description: json['description'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      isAddcart: json['isAddcart'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produkID': produkID,
      'nama': nama,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAddcart': isAddcart,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CreateProductRequest {
  final String nama;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;

  CreateProductRequest({
    required this.nama,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  Map<String, String> toFields() {
    return {
      'nama': nama,
      'description': description,
      'price': price.toString(),
      'category': category,
    };
  }
}