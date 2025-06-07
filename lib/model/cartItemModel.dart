import 'package:hive/hive.dart';

part 'cartItemModel.g.dart';

@HiveType(typeId: 0) // Unique typeId for this model
class CartItem extends HiveObject {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  // Method to update quantity
  void updateQuantity(int newQuantity) {
    if (newQuantity >= 0) {
      quantity = newQuantity;
    }
  }
}
