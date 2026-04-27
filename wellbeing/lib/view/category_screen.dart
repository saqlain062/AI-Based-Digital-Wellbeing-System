import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/category_service.dart';
import '../services/hive_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService service = Get.put(CategoryService());
  final List<String> categoryOptions = [
    'Social',
    'Game',
    'Entertainment',
    'Productivity',
    'News',
    'Finance',
    'Travel',
    'Education',
    'Shopping',
    'Other',
  ];

  final List<String> displayOrder = [
    'Social',
    'Game',
    'Entertainment',
    'Productivity',
    'News',
    'Finance',
    'Travel',
    'Education',
    'Shopping',
    'Other',
  ];

  // Color mapping for different categories
  final Map<String, Color> categoryColors = {
    'Social': Colors.blue,
    'Game': Colors.green,
    'Entertainment': Colors.orange,
    'Productivity': Colors.purple,
    'News': Colors.red,
    'Finance': Colors.teal,
    'Travel': Colors.cyan,
    'Education': Colors.indigo,
    'Shopping': Colors.pink,
    'Other': Colors.grey,
  };

  Map<String, List<Map<String, dynamic>>> groupedApps = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Scan for new apps and remove uninstalled ones
      // User's manual category changes are preserved!
      final installed = await service.scanInstalledApps();
      groupedApps = {};

      for (var item in installed) {
        final category = item['category']?.toString() ?? 'Other';
        final groupKey = category.isEmpty ? 'Other' : category;
        groupedApps.putIfAbsent(groupKey, () => []).add(item);
      }
    } catch (e) {
      errorMessage = 'Unable to load categories. Please try again.';
      groupedApps = {};
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh categories',
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : groupedApps.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: displayOrder
                  .where(
                    (key) =>
                        groupedApps.containsKey(key) &&
                        groupedApps[key]!.isNotEmpty,
                  )
                  .expand((category) {
                    final apps = groupedApps[category]!;
                    return [
                      _buildCategoryHeader(category),
                      ...apps.map((item) => _buildAppTile(item)).toList(),
                    ];
                  })
                  .toList(),
            ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        category,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAppTile(Map<String, dynamic> item) {
    final package = item['packageName']?.toString() ?? 'unknown';
    final appName = item['appName']?.toString() ?? 'Unknown App';
    final category = item['category']?.toString() ?? 'Other';
    final avatarColor = categoryColors[category] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: avatarColor,
          child: Text(
            appName.isNotEmpty ? appName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(appName),
        subtitle: Text(package, style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            await service.saveUserCategory(package, value);
            if (mounted) {
              setState(() {
                final existingCategory =
                    item['category']?.toString() ?? 'Other';
                groupedApps[existingCategory]?.remove(item);
                item['category'] = value;
                groupedApps.putIfAbsent(value, () => []).add(item);
              });
            }
          },
          itemBuilder: (context) => categoryOptions
              .map((e) => PopupMenuItem(value: e, child: Text(e)))
              .toList(),
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_outlined, size: 72, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No category data found yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap refresh to scan installed apps and populate categories.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Installed Apps'),
          ),
        ],
      ),
    );
  }
}
