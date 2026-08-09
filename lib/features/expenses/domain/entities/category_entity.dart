import 'package:flutter/material.dart';

class CategoryEntity {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<CategoryEntity> defaultCategories = [
    CategoryEntity(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFEF4444),
    ),
    CategoryEntity(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFF8B5CF6),
    ),
    CategoryEntity(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_bus_outlined,
      color: Color(0xFF06B6D4),
    ),
    CategoryEntity(
      id: 'housing',
      name: 'Housing & Rent',
      icon: Icons.home_outlined,
      color: Color(0xFFF59E0B),
    ),
    CategoryEntity(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      color: Color(0xFFEC4899),
    ),
    CategoryEntity(
      id: 'salary',
      name: 'Salary & Income',
      icon: Icons.attach_money_outlined,
      color: Color(0xFF10B981),
    ),
    CategoryEntity(
      id: 'bills',
      name: 'Utilities & Bills',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF3B82F6),
    ),
    CategoryEntity(
      id: 'health',
      name: 'Healthcare',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF14B8A6),
    ),
  ];
}
