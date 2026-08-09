import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    final categoryId = json['id'] as String;
    final found = CategoryEntity.defaultCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryEntity(
        id: categoryId,
        name: json['name'] as String? ?? 'General',
        icon: Icons.category_outlined,
        color: Color(json['colorHex'] as int? ?? 0xFF6366F1),
      ),
    );

    return CategoryModel(
      id: found.id,
      name: json['name'] as String? ?? found.name,
      icon: found.icon,
      color: found.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorHex': color.toARGB32(),
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
    );
  }
}
