import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../controller/onboarding_controller.dart';
import '../../services/hive_service.dart';
import '../../util/theme/wellbeing_theme.dart';
import '../category_screen.dart';
import '../dashboard/ai_module_widgets.dart';
import '../fresh_start_screen.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  late bool localHistoryEnabled;
  late int historyCount;
  late int categoryCount;
  Map<String, dynamic>? lastAnalysis;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final history = HiveService.instance.getAnalysisHistory();
    final latest = HiveService.instance.getUser('lastAnalysis');

    setState(() {
      localHistoryEnabled = HiveService.instance.getBool(
        'localHistoryEnabled',
        defaultValue: true,
      );
      historyCount = history.length;
      categoryCount = HiveService.instance.getAllCategories().length;
      lastAnalysis = latest is Map ? Map<String, dynamic>.from(latest) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final latestScore = _latestScoreLabel();
    final latestDate = _latestDateLabel();

    return AiModuleScaffold(
      title: 'Data Management',
      subtitle:
          'Review what is stored on this device, keep your history tidy, and reset local insights whenever you want a fresh start.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(child: _buildHeroCard(context, latestScore, latestDate)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 80, child: _buildStoredDataCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 140, child: _buildHistoryCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 220, child: _buildCategoriesCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 300, child: _buildResetCard(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    String latestScore,
    String latestDate,
  ) {
    return AiGlassCard(
      gradient: WellbeingTheme.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.shield_outlined,
            title: 'Private by Design',
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your wellbeing data stays on this device. No account is required, and you stay in control of what is kept for future trends.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiMetricPill(label: 'Latest result', value: latestScore),
              AiMetricPill(label: 'History saved', value: '$historyCount days'),
              AiMetricPill(label: 'Updated', value: latestDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoredDataCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.storage_rounded,
            title: 'Stored on This Device',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 14),
          Text(
            'Here is the local data the app uses to keep your experience consistent and useful.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _DataRow(
            icon: Icons.person_outline_rounded,
            title: 'Profile and wellbeing inputs',
            subtitle:
                'Age, sleep, stress, work or study hours, and related check-in details.',
          ),
          const SizedBox(height: 12),
          _DataRow(
            icon: Icons.auto_graph_rounded,
            title: 'Latest analysis result',
            subtitle: lastAnalysis == null
                ? 'No saved result yet.'
                : 'Your latest prediction, confidence, and recommendation are ready to reopen.',
          ),
          const SizedBox(height: 12),
          _DataRow(
            icon: Icons.bar_chart_rounded,
            title: 'Daily history',
            subtitle: localHistoryEnabled
                ? historyCount == 0
                      ? 'History is on, but daily snapshots have not been saved yet.'
                      : '$historyCount daily snapshot${historyCount == 1 ? '' : 's'} are available for weekly and monthly trends.'
                : 'History saving is currently turned off in Settings.',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.history_rounded,
            title: 'History and Trends',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 16),
          _StatusTile(
            icon: Icons.bar_chart_rounded,
            title: localHistoryEnabled
                ? 'Daily history is active'
                : 'Daily history is paused',
            subtitle: localHistoryEnabled
                ? historyCount == 0
                      ? 'The app is ready to save daily snapshots as new analyses are created.'
                      : 'Your weekly charts and trend summaries are built from $historyCount saved day${historyCount == 1 ? '' : 's'}.'
                : 'Turn history back on in Settings whenever you want trend tracking again.',
            trailing: AiStatusBadge(
              label: localHistoryEnabled ? 'On-device' : 'Paused',
              color: localHistoryEnabled
                  ? AiModulePalette.success
                  : AiModulePalette.warning,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AiSecondaryButton(
                  label: 'Clear History',
                  onPressed: historyCount == 0 ? null : _confirmClearHistory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.category_outlined,
            title: 'App Categories',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 16),
          _StatusTile(
            icon: Icons.apps_rounded,
            title: categoryCount == 0
                ? 'Using default app categories'
                : '$categoryCount custom categor${categoryCount == 1 ? 'y' : 'ies'} saved',
            subtitle: categoryCount == 0
                ? 'Your app activity is currently grouped using the built-in category map.'
                : 'Custom category choices are saved locally so reports stay consistent with your preferences.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AiSecondaryButton(
                  label: 'Review Categories',
                  onPressed: () async {
                    await Get.to(() => const CategoryScreen());
                    _refreshData();
                  },
                ),
              ),
              if (categoryCount > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: AiSecondaryButton(
                    label: 'Reset Categories',
                    onPressed: _confirmClearCategories,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResetCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.restart_alt_rounded,
            title: 'Reset Local Insights',
            color: AiModulePalette.danger,
          ),
          const SizedBox(height: 14),
          Text(
            'This clears the saved prediction, personal setup values, stored feature values, and trend history on this device. You will be guided back through setup so a new result can be calculated from fresh inputs.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AiModulePalette.danger.withAlpha(20),
              border: Border.all(color: AiModulePalette.danger.withAlpha(70)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AiModulePalette.danger,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Permissions, reminders, and app preferences stay in place. Your age and wellbeing inputs will be entered again during setup.',
                    style: TextStyle(
                      color: AiModulePalette.textPrimary(context),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AiPrimaryButton(
              label: 'Reset Local Insights',
              onPressed: _confirmResetInsights,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Clear history?',
      message:
          'This will remove saved daily trend snapshots from this device. Your latest result and profile details will stay in place.',
      confirmLabel: 'Clear History',
    );
    if (!confirmed) return;

    HiveService.instance.clearAnalysisHistory();
    _refreshData();
    _showMessage('Daily history cleared.');
  }

  Future<void> _confirmClearCategories() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Reset app categories?',
      message:
          'This will remove your custom app category choices and return activity reports to the built-in category map.',
      confirmLabel: 'Reset Categories',
    );
    if (!confirmed) return;

    HiveService.instance.clearCategoryOverrides();
    _refreshData();
    _showMessage('Custom app categories reset.');
  }

  Future<void> _confirmResetInsights() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Reset local insights?',
      message:
          'This will clear the saved prediction, personal setup inputs, stored feature values, and daily history from this device. You will return to setup to calculate a fresh result.',
      confirmLabel: 'Reset',
    );
    if (!confirmed) return;

    HiveService.instance.clearLocalInsights();
    HiveService.instance.clearProfileData();
    HiveService.instance.saveBool('onboardingCompleted', false);
    HiveService.instance.saveBool('needsFreshStart', true);
    if (Get.isRegistered<AIController>()) {
      Get.find<AIController>().resetLocalState();
    }
    if (Get.isRegistered<OnboardingController>()) {
      Get.delete<OnboardingController>(force: true);
    }
    _refreshData();
    Get.offAll(() => const FreshStartScreen());
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final textPrimary = AiModulePalette.textPrimary(context);
    final textSecondary = AiModulePalette.textSecondary(context);
    final surface = WellbeingDecor.surface(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  color: AiModulePalette.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showMessage(String message) {
    Get.snackbar(
      'Done',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: WellbeingDecor.surface(context),
      colorText: AiModulePalette.textPrimary(context),
      margin: const EdgeInsets.all(16),
    );
  }

  String _latestScoreLabel() {
    final score = lastAnalysis?['score'];
    if (score is num) {
      return '${(score * 100).round()}%';
    }
    return 'Not saved yet';
  }

  String _latestDateLabel() {
    final timestamp = lastAnalysis?['timestamp']?.toString();
    if (timestamp == null || timestamp.isEmpty) {
      return 'No recent save';
    }

    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) {
      return 'Recently';
    }

    final date = parsed.toLocal();
    final month = _monthLabel(date.month);
    final day = date.day.toString().padLeft(2, '0');
    return '$day $month';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final safeIndex = month < 1 ? 0 : (month > 12 ? 11 : month - 1);
    return months[safeIndex];
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AiModulePalette.blue.withAlpha(18),
          ),
          child: Icon(icon, color: AiModulePalette.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AiModulePalette.textPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AiModulePalette.textSecondary(context),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AiModulePalette.teal.withAlpha(18),
            ),
            child: Icon(icon, color: AiModulePalette.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AiModulePalette.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AiModulePalette.textSecondary(context),
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
