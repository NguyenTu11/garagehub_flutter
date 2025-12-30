import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/PartModel.dart';

class CartNotifier {
  static final ValueNotifier<int> cartCount = ValueNotifier<int>(0);

  static void updateCount(int count) {
    cartCount.value = count;
  }

  static Future<void> refresh() async {
    final service = CartService();
    final count = await service.getItemCount();
    cartCount.value = count;
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'unit': unit,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  factory CartItem.fromPart(PartModel part, {int quantity = 1}) {
    return CartItem(
      id: part.id ?? '',
      name: part.name,
      price: part.price,
      image: part.image,
      unit: part.unit,
      quantity: quantity,
    );
  }
}

class CartService {
  static const String _cartKey = 'cart_items';

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return [];

    final List<dynamic> cartList = json.decode(cartJson);
    return cartList.map((e) => CartItem.fromJson(e)).toList();
  }

  Future<void> addToCart(PartModel part, {int quantity = 1}) async {
    final items = await getCartItems();
    final existingIndex = items.indexWhere((item) => item.id == part.id);

    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem.fromPart(part, quantity: quantity));
    }

    await _saveCart(items);
    await _notifyCountChange();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
      await _saveCart(items);
      await _notifyCountChange();
    }
  }

  Future<void> removeFromCart(String itemId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveCart(items);
    await _notifyCountChange();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    CartNotifier.updateCount(0);
  }

  Future<double> getTotal() async {
    final items = await getCartItems();
    double total = 0.0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<int> getItemCount() async {
    final items = await getCartItems();
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  Future<void> _saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  Future<void> _notifyCountChange() async {
    final count = await getItemCount();
    CartNotifier.updateCount(count);
  }
}
