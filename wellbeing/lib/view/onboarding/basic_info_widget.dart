import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/onboarding_controller.dart';

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tell us about you",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Help us personalize your experience",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 40),

          // Age Section
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
                      Icon(Icons.calendar_today, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        "Age",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(
                        () => Text(
                          c.age.value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Text(" years old", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Obx(
                    () => Slider(
                      value: c.age.value,
                      min: 10,
                      max: 60,
                      divisions: 50,
                      label: c.age.value.toStringAsFixed(0),
                      activeColor: Colors.green,
                      onChanged: (v) => c.age.value = v,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Gender Section
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
                      Icon(Icons.person, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Wrap(
                      spacing: 12,
                      children: [
                        ChoiceChip(
                          label: const Text("Female"),
                          selected: c.gender.value == 0,
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => c.gender.value = 0,
                          avatar: const Icon(Icons.female, color: Colors.pink),
                        ),
                        ChoiceChip(
                          label: const Text("Male"),
                          selected: c.gender.value == 1,
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => c.gender.value = 1,
                          avatar: const Icon(Icons.male, color: Colors.green),
                        ),
                        ChoiceChip(
                          label: const Text("Other"),
                          selected: c.gender.value == 2,
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => c.gender.value = 2,
                          avatar: const Icon(
                            Icons.person_outline,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
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
    );
  }
}
