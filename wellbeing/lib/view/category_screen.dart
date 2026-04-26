import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/category_service.dart';
import '../services/hive_service.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final CategoryService service = Get.put(CategoryService());

  final List<String> categories = [
    "Social",
    "Game",
    "Entertainment",
    "Productivity",
    "News",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    final data = HiveService.instance.getAllCategories();

    return Scaffold(
      appBar: AppBar(title: const Text("App Categories")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final package = data.keys.elementAt(index);
          final category = data[package];

          return Card(
            child: ListTile(
              title: Text(package),
              subtitle: Text("Category: $category"),

              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  await service.saveUserCategory(package, value);
                },
                itemBuilder: (context) => categories
                    .map((e) => PopupMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
