import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/onboarding_controller.dart';

class BehaviorWidget extends StatelessWidget {
  const BehaviorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your mindset",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Help us understand your stress levels and academic challenges",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 40),

          // Stress Mood Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "How stressed do you feel?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Be honest — this helps us support you better.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(c.moodLabels.length, (index) {
                        final selected = c.selectedMood.value == index;
                        return ChoiceChip(
                          avatar: Text(
                            c.moodEmojis[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                          label: Text(c.moodLabels[index]),
                          selected: selected,
                          selectedColor: Colors.green.shade100,
                          backgroundColor: Colors.grey.shade100,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => c.selectMood(index),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Text(
                      "You selected: ${c.moodLabels[c.selectedMood.value]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Academic Impact Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        "Academic Impact (1-10)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "How much does smartphone use affect your studies?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(
                        () => Text(
                          c.academicImpact.value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Text(" / 10", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Obx(
                    () => Slider(
                      value: c.academicImpact.value,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: c.academicImpact.value.toStringAsFixed(0),
                      activeColor: Colors.green,
                      onChanged: (v) => c.academicImpact.value = v,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              TextButton(
                onPressed: c.back,
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text("Back", style: TextStyle(fontSize: 16)),
              ),
              const Spacer(),
              SizedBox(
                width: 130,
                height: 50,
                child: ElevatedButton(
                  onPressed: c.next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
