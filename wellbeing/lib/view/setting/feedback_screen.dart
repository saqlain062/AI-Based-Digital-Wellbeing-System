import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dashboard/ai_module_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static final Uri _feedbackBaseUri = Uri.parse(
    'https://docs.google.com/forms/d/e/1FAIpQLSdysvqWFryorGpd57F_OFT41a94eEnRW0AogtRkd55kN9dy4g/viewform',
  );

  int? selectedRating;
  final TextEditingController helpfulController = TextEditingController();
  final TextEditingController improveController = TextEditingController();
  final Set<String> selectedTopics = <String>{};

  static const List<String> topics = [
    'Prediction clarity',
    'Tracking accuracy',
    'Recommendations',
    'Design',
    'Performance',
    'Privacy',
  ];

  @override
  void dispose() {
    helpfulController.dispose();
    improveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AiModuleScaffold(
      title: 'Share Feedback',
      subtitle:
          'A few thoughtful notes are enough. Your feedback helps us make the app calmer, clearer, and more useful.',
      showBack: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiFadeSlideIn(child: _buildHeroCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 100, child: _buildRatingCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 180, child: _buildTopicsCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 260, child: _buildWritingCard(context)),
            const SizedBox(height: 18),
            AiFadeSlideIn(delayMs: 340, child: _buildSubmitCard(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return AiGlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AiModulePalette.blue,
          AiModulePalette.purple,
          AiModulePalette.teal,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AiSectionTitle(
            icon: Icons.rate_review_outlined,
            title: 'Your voice shapes the app',
            color: Colors.white,
          ),
          SizedBox(height: 14),
          Text(
            'You do not need to write much. Even one clear note about what felt useful or frustrating can help guide the next improvements.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.favorite_border_rounded,
            title: 'Overall Experience',
            color: AiModulePalette.teal,
          ),
          const SizedBox(height: 14),
          Text(
            'How has the app felt to use so far?',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final selected = selectedRating == rating;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 10),
                  child: InkWell(
                    onTap: () => setState(() => selectedRating = rating),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  AiModulePalette.blue,
                                  AiModulePalette.purple,
                                ],
                              )
                            : null,
                        color: selected
                            ? null
                            : Colors.white.withAlpha(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 12
                                    : 110,
                              ),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : Colors.white.withAlpha(24),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$rating',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AiModulePalette.textPrimary(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.tune_rounded,
            title: 'What Is This About?',
            color: AiModulePalette.purple,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: topics.map((topic) {
              final selected = selectedTopics.contains(topic);

              return FilterChip(
                selected: selected,
                label: Text(topic),
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      selectedTopics.remove(topic);
                    } else {
                      selectedTopics.add(topic);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionTitle(
            icon: Icons.edit_note_rounded,
            title: 'A Few Notes',
            color: AiModulePalette.blue,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: helpfulController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What is working well?',
              hintText: 'Tell us what felt clear, helpful, or reassuring.',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: improveController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What could feel better?',
              hintText: 'Share anything that felt confusing, slow, or missing.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitCard(BuildContext context) {
    return AiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When you send feedback, the app opens a simple Google Form with your notes already filled in.',
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AiPrimaryButton(
            label: 'Send Feedback',
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final queryParts = <String>[
      'usp=pp_url',
      if (selectedRating != null)
        'entry.2005620554=${Uri.encodeQueryComponent(selectedRating.toString())}',
      ...selectedTopics.map(
        (topic) =>
            'entry.1045781291=${Uri.encodeQueryComponent(topic)}',
      ),
      if (helpfulController.text.trim().isNotEmpty)
        'entry.1065046570=${Uri.encodeQueryComponent(helpfulController.text.trim())}',
      if (improveController.text.trim().isNotEmpty)
        'entry.1166974658=${Uri.encodeQueryComponent(improveController.text.trim())}',
    ];

    final uri = Uri.parse(
      '${_feedbackBaseUri.toString()}?${queryParts.join('&')}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        if (mounted) {
          Get.back();
        }
        return;
      }

      if (!mounted) return;

      Get.snackbar(
        'Could not open form',
        'Please try again in a moment.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
    } on PlatformException {
      if (!mounted) return;

      Get.snackbar(
        'Restart required',
        'Please fully restart the app once so feedback links can open correctly.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
    } catch (_) {
      if (!mounted) return;

      Get.snackbar(
        'Could not open form',
        'Please try again in a moment.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
    }
  }
}
