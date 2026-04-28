import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/usage_feature_service.dart';
import '../services/category_service.dart';
import '../util/time_formatter.dart';
import '../widget/appbar/appbar.dart';

class AppDetailsScreen extends StatelessWidget {
  const AppDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usageService = UsageFeatureService(CategoryService());

    return Scaffold(
      appBar: SAppBar(
        title: const Text("Apps Usage Breakdown"),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: usageService.getTopApps(limit: 1000), // Get all apps
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No app usage data available'));
          }

          final allApps = snapshot.data!;

          // Group apps by category
          final Map<String, List<Map<String, dynamic>>> groupedApps = {};

          for (var app in allApps) {
            final category = app['category'] ?? 'Other';
            if (!groupedApps.containsKey(category)) {
              groupedApps[category] = [];
            }
            groupedApps[category]!.add(app);
          }

          // Sort categories (Social at top, then rest alphabetically)
          final sortedCategories = groupedApps.keys.toList();
          sortedCategories.sort((a, b) {
            if (a == 'Social') return -1;
            if (b == 'Social') return 1;
            if (a == 'Game') return -1;
            if (b == 'Game') return 1;
            return a.compareTo(b);
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Total usage card
                  _buildTotalCard(allApps),
                  const SizedBox(height: 20),
                  // Category sections
                  ...sortedCategories.map(
                    (category) =>
                        _buildCategorySection(category, groupedApps[category]!),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCard(List<Map<String, dynamic>> apps) {
    double totalHours = 0;
    for (var app in apps) {
      totalHours += (app['usageHours'] as double);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total App Usage',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                TimeFormatter.formatHours(totalHours),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          Icon(Icons.apps, size: 40, color: Colors.blue.shade300),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<Map<String, dynamic>> apps,
  ) {
    // Calculate total for category
    double categoryTotal = 0;
    for (var app in apps) {
      categoryTotal += (app['usageHours'] as double);
    }

    // Get category color
    Color categoryColor = _getCategoryColor(category);

    // Sort apps by usage
    apps.sort(
      (a, b) =>
          (b['usageHours'] as double).compareTo(a['usageHours'] as double),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: categoryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: categoryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  TimeFormatter.formatHours(categoryTotal),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
          // App list
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ...apps.asMap().entries.map((entry) {
                  int index = entry.key;
                  var app = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < apps.length - 1 ? 12 : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app['appName'] ??
                                    app['packageName'] ??
                                    'Unknown',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app['packageName'] ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          TimeFormatter.formatHours(
                            app['usageHours'] as double,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Social':
        return Colors.pink;
      case 'Game':
        return Colors.purple;
      case 'Productivity':
        return Colors.blue;
      case 'Entertainment':
        return Colors.orange;
      case 'Communication':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Social':
        return Icons.people;
      case 'Game':
        return Icons.sports_esports;
      case 'Productivity':
        return Icons.work;
      case 'Entertainment':
        return Icons.movie;
      case 'Communication':
        return Icons.chat;
      default:
        return Icons.app_shortcut;
    }
  }
}
