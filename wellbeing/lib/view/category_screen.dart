import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/category_service.dart';
import 'dashboard/ai_module_widgets.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService service = Get.put(CategoryService());

  final List<String> categoryOptions = const [
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

  final List<String> displayOrder = const [
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
      final installed = await service.scanInstalledApps(includeIcons: true);
      final nextGroups = <String, List<Map<String, dynamic>>>{};

      for (final item in installed) {
        final category = item['category']?.toString() ?? 'Other';
        final groupKey = category.isEmpty ? 'Other' : category;
        nextGroups.putIfAbsent(groupKey, () => []).add(item);
      }

      for (final apps in nextGroups.values) {
        apps.sort((a, b) {
          final left = (a['appName']?.toString() ?? '').toLowerCase();
          final right = (b['appName']?.toString() ?? '').toLowerCase();
          return left.compareTo(right);
        });
      }

      if (!mounted) return;
      setState(() {
        groupedApps = nextGroups;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage =
            'We could not refresh your app groups just now. Please try again.';
        groupedApps = {};
      });
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
    return AiModuleScaffold(
      title: 'App Categories',
      subtitle:
          'Review how your installed apps are grouped across activity, reports, and AI insights.',
      showBack: true,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildMessageState(context, errorMessage!)
          : groupedApps.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  AiFadeSlideIn(child: _buildHeroCard(context)),
                  const SizedBox(height: 18),
                  ...displayOrder.where((key) {
                    return groupedApps.containsKey(key) &&
                        groupedApps[key]!.isNotEmpty;
                  }).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final apps = groupedApps[category]!;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == groupedApps.length - 1 ? 0 : 18,
                      ),
                      child: AiFadeSlideIn(
                        delayMs: 80 + (index * 40),
                        child: _buildCategorySection(context, category, apps),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final totalApps = groupedApps.values.fold<int>(
      0,
      (sum, apps) => sum + apps.length,
    );
    final activeGroups = groupedApps.values.where((apps) => apps.isNotEmpty).length;

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.category_outlined,
            title: 'Your App Groups',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            'Adjusting categories helps your activity views feel more accurate and personal.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiMetricPill(label: 'Installed apps', value: '$totalApps'),
              AiMetricPill(label: 'Active groups', value: '$activeGroups'),
              AiMetricPill(label: 'Refresh', value: 'Pull down'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<Map<String, dynamic>> apps,
  ) {
    final accent = _categoryColor(category);

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: accent.withAlpha(20),
                ),
                child: Icon(_categoryIcon(category), color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: AiModulePalette.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${apps.length} app${apps.length == 1 ? '' : 's'} in this group',
                      style: TextStyle(
                        color: AiModulePalette.textSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...apps.map((item) => _buildAppTile(context, item)),
        ],
      ),
    );
  }

  Widget _buildAppTile(BuildContext context, Map<String, dynamic> item) {
    final package = item['packageName']?.toString() ?? 'unknown';
    final appName = item['appName']?.toString() ?? 'Unknown App';
    final category = item['category']?.toString() ?? 'Other';
    final accent = _categoryColor(category);
    final iconBytes = item['iconBytes'] as Uint8List?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withAlpha(
            Theme.of(context).brightness == Brightness.dark ? 14 : 120,
          ),
          border: Border.all(color: Colors.white.withAlpha(24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AiAppIcon(name: appName, iconBytes: iconBytes),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AiModulePalette.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Currently grouped as $category. Change this if another category feels like a better fit.',
                    style: TextStyle(
                      color: AiModulePalette.textSecondary(context),
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _CategoryTag(label: category, color: accent),
                      Text(
                        _packageHint(package),
                        style: TextStyle(
                          color: AiModulePalette.textSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              tooltip: 'Change category',
              onSelected: (value) async {
                await service.saveUserCategory(package, value);
                if (!mounted) return;

                setState(() {
                  final existingCategory =
                      item['category']?.toString() ?? 'Other';
                  groupedApps[existingCategory]?.remove(item);
                  item['category'] = value;
                  groupedApps.putIfAbsent(value, () => []).add(item);
                  groupedApps.removeWhere((key, value) => value.isEmpty);
                });
              },
              itemBuilder: (context) => categoryOptions
                  .map(
                    (option) => PopupMenuItem<String>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcon(option),
                            color: _categoryColor(option),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(option),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              icon: Icon(
                Icons.swap_horiz_rounded,
                color: AiModulePalette.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return _buildMessageState(
      context,
      'No app groups are ready to review yet. Pull to refresh after the app has had a chance to read your installed apps.',
      icon: Icons.category_outlined,
      actionLabel: 'Refresh App Groups',
      onPressed: _loadCategories,
    );
  }

  Widget _buildMessageState(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    String? actionLabel,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AiGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: AiModulePalette.teal),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AiModulePalette.textPrimary(context),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (actionLabel != null && onPressed != null) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: AiPrimaryButton(
                    label: actionLabel,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _packageHint(String package) {
    final parts = package.split('.');
    if (parts.length >= 2) {
      final publisher = parts[parts.length - 2];
      return 'From ${_humanizeToken(publisher)}';
    }
    return 'Installed on this device';
  }

  String _humanizeToken(String value) {
    final cleaned = value.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (cleaned.isEmpty) {
      return 'this publisher';
    }

    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Social':
        return AiModulePalette.blue;
      case 'Game':
        return AiModulePalette.purple;
      case 'Entertainment':
        return const Color(0xFFF59E0B);
      case 'Productivity':
        return const Color(0xFF6366F1);
      case 'News':
        return const Color(0xFFDC2626);
      case 'Finance':
        return const Color(0xFF0F766E);
      case 'Travel':
        return const Color(0xFF0891B2);
      case 'Education':
        return const Color(0xFF7C3AED);
      case 'Shopping':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Social':
        return Icons.people_alt_rounded;
      case 'Game':
        return Icons.sports_esports_rounded;
      case 'Entertainment':
        return Icons.movie_creation_outlined;
      case 'Productivity':
        return Icons.work_outline_rounded;
      case 'News':
        return Icons.newspaper_outlined;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      case 'Travel':
        return Icons.flight_takeoff_rounded;
      case 'Education':
        return Icons.school_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.apps_rounded;
    }
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(48)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
