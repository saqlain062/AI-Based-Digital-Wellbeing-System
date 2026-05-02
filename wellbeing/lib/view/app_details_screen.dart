import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/category_service.dart';
import '../services/usage_feature_service.dart';
import '../util/time_formatter.dart';
import 'dashboard/ai_module_widgets.dart';

class AppDetailsScreen extends StatefulWidget {
  const AppDetailsScreen({super.key});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  late Future<List<Map<String, dynamic>>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = UsageFeatureService(
      CategoryService(),
    ).getTopApps(limit: 1000, includeIcons: true);
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'App Activity',
      subtitle:
          'A clearer look at which apps are taking the most of your attention right now.',
      showBack: true,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final apps = snapshot.data ?? const <Map<String, dynamic>>[];
          if (snapshot.hasError || apps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'There is not enough app activity to show here yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          final groupedApps = _groupApps(apps);
          final sortedCategories = groupedApps.keys.toList()
            ..sort((a, b) {
              final priorityCompare = _categoryPriority(
                a,
              ).compareTo(_categoryPriority(b));
              if (priorityCompare != 0) {
                return priorityCompare;
              }
              return a.compareTo(b);
            });
          final totalHours = apps.fold<double>(
            0.0,
            (sum, app) => sum + ((app['usageHours'] as double?) ?? 0),
          );
          final topApp = apps.first;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiFadeSlideIn(
                  child: _buildHeroSummary(context, apps, totalHours, topApp),
                ),
                const SizedBox(height: 18),
                AiFadeSlideIn(
                  delayMs: 100,
                  child: _buildHighlightsCard(context, apps),
                ),
                const SizedBox(height: 18),
                ...sortedCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == sortedCategories.length - 1 ? 0 : 18,
                    ),
                    child: AiFadeSlideIn(
                      delayMs: 180 + (index * 40),
                      child: _buildCategorySection(
                        context,
                        category,
                        groupedApps[category]!,
                        totalHours,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSummary(
    BuildContext context,
    List<Map<String, dynamic>> apps,
    double totalHours,
    Map<String, dynamic> topApp,
  ) {
    final topAppName = (topApp['appName'] as String?) ?? 'Unknown App';
    final topAppUsage = (topApp['usageHours'] as double?) ?? 0;

    return AiGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AiModulePalette.blue.withAlpha(210),
          AiModulePalette.purple.withAlpha(190),
          AiModulePalette.teal.withAlpha(175),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.apps_rounded,
            title: 'Today\'s Activity',
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActivityMetricPill(
                label: 'Total usage',
                value: TimeFormatter.formatHoursShort(totalHours),
              ),
              _ActivityMetricPill(label: 'Apps used', value: '${apps.length}'),
              _ActivityMetricPill(label: 'Most active app', value: topAppName),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$topAppName is leading your activity right now at ${TimeFormatter.formatHoursShort(topAppUsage)}.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard(
    BuildContext context,
    List<Map<String, dynamic>> apps,
  ) {
    final topThree = apps.take(3).toList();
    final maxUsage = topThree.fold<double>(0.0, (current, app) {
      final next = (app['usageHours'] as double?) ?? 0;
      return next > current ? next : current;
    });

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.flash_on_rounded,
            title: 'Top Apps Right Now',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          ...topThree.map((app) {
            final hours = (app['usageHours'] as double?) ?? 0;
            final progress = maxUsage <= 0 ? 0.0 : hours / maxUsage;
            final accent = _appAccent(app);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    child: AiAppIcon(
                      name: (app['appName'] as String?) ?? 'Unknown App',
                      iconBytes: app['iconBytes'] as Uint8List?,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (app['appName'] as String?) ?? 'Unknown App',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AiModulePalette.textPrimary(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              TimeFormatter.formatHoursShort(hours),
                              style: TextStyle(
                                color: AiModulePalette.textSecondary(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white.withAlpha(24),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<Map<String, dynamic>> apps,
    double totalHours,
  ) {
    final categoryColor = _categoryColor(category);
    final categoryTotal = apps.fold<double>(
      0.0,
      (sum, app) => sum + ((app['usageHours'] as double?) ?? 0),
    );
    final share = totalHours <= 0 ? 0.0 : categoryTotal / totalHours;

    apps.sort(
      (a, b) =>
          (b['usageHours'] as double).compareTo(a['usageHours'] as double),
    );

    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: categoryColor.withAlpha(24),
                ),
                child: Icon(
                  _categoryIcon(category),
                  color: categoryColor,
                  size: 18,
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${TimeFormatter.formatHoursShort(categoryTotal)}  |  ${(share * 100).round()}% of today',
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
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(24),
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            ),
          ),
          const SizedBox(height: 16),
          ...apps.map(
            (app) => _buildAppRow(context, app, categoryTotal, categoryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow(
    BuildContext context,
    Map<String, dynamic> app,
    double categoryTotal,
    Color categoryColor,
  ) {
    final usage = (app['usageHours'] as double?) ?? 0;
    final share = categoryTotal <= 0 ? 0.0 : usage / categoryTotal;
    final category = (app['category'] as String?) ?? 'Other';
    final accent = _appAccent(app);
    final insight = '${(share * 100).round()}% of this category';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withAlpha(
            Theme.of(context).brightness == Brightness.dark ? 14 : 120,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AiAppIcon(
                  name:
                      (app['appName'] as String?) ??
                      (app['packageName'] as String?) ??
                      'Unknown App',
                  iconBytes: app['iconBytes'] as Uint8List?,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (app['appName'] as String?) ??
                            (app['packageName'] as String?) ??
                            'Unknown App',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AiModulePalette.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AiModulePalette.textSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  TimeFormatter.formatHoursShort(usage),
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _MiniTag(label: category, color: accent),
                const SizedBox(width: 12),
                Text(
                  '${(share * 100).round()}% of ${category.toLowerCase()} time',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 6,
                backgroundColor: Colors.white.withAlpha(18),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupApps(
    List<Map<String, dynamic>> apps,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final app in apps) {
      final category = (app['category'] as String?) ?? 'Other';
      grouped.putIfAbsent(category, () => <Map<String, dynamic>>[]).add(app);
    }

    return grouped;
  }

  int _categoryPriority(String category) {
    switch (category) {
      case 'Social':
        return 0;
      case 'Communication':
        return 1;
      case 'Entertainment':
        return 2;
      case 'Productivity':
        return 3;
      case 'Finance':
        return 4;
      case 'Education':
        return 5;
      case 'Shopping':
        return 6;
      case 'Travel':
        return 7;
      case 'News':
        return 8;
      case 'Game':
        return 9;
      default:
        return 10;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Social':
        return AiModulePalette.blue;
      case 'Communication':
        return AiModulePalette.teal;
      case 'Entertainment':
        return const Color(0xFFF59E0B);
      case 'Productivity':
        return const Color(0xFF6366F1);
      case 'Finance':
        return const Color(0xFF0F766E);
      case 'Education':
        return const Color(0xFF7C3AED);
      case 'Shopping':
        return const Color(0xFFDB2777);
      case 'Travel':
        return const Color(0xFF0891B2);
      case 'News':
        return const Color(0xFFDC2626);
      case 'Game':
        return AiModulePalette.purple;
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Social':
        return Icons.people_alt_rounded;
      case 'Communication':
        return Icons.chat_bubble_outline_rounded;
      case 'Entertainment':
        return Icons.movie_creation_outlined;
      case 'Productivity':
        return Icons.work_outline_rounded;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      case 'Education':
        return Icons.school_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Travel':
        return Icons.flight_takeoff_rounded;
      case 'News':
        return Icons.newspaper_outlined;
      case 'Game':
        return Icons.sports_esports_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Color _appAccent(Map<String, dynamic> app) {
    final category = (app['category'] as String?) ?? 'Other';
    final name = ((app['appName'] as String?) ?? '').toLowerCase();

    if (name.contains('youtube')) return const Color(0xFFFF5B6E);
    if (name.contains('instagram')) return const Color(0xFFE879F9);
    if (name.contains('whatsapp')) return const Color(0xFF22C55E);
    if (name.contains('facebook')) return const Color(0xFF3B82F6);
    if (name.contains('chrome')) return const Color(0xFF38BDF8);
    if (name.contains('spotify')) return const Color(0xFF10B981);
    if (name.contains('tiktok')) return const Color(0xFF8B5CF6);

    return _categoryColor(category);
  }

}

class _ActivityMetricPill extends StatelessWidget {
  const _ActivityMetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(50)),
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
