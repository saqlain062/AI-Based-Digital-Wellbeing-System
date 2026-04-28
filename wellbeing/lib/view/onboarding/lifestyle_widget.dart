import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/onboarding_controller.dart';

class LifestyleWidget extends StatelessWidget {
  const LifestyleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OnboardingController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your daily routine",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Set your sleep window and work hours for a smarter estimate.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 40),

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
                  Obx(
                    () => SwitchListTile.adaptive(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.green,
                      title: const Text(
                        'Estimate from bedtime / wake time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        c.showSleepIndicator.value
                            ? 'Drag the slider to set your sleep duration manually.'
                            : 'Sleep length is calculated from your selected window.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      value: c.showSleepIndicator.value,
                      onChanged: c.toggleSleepIndicator,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Obx(
                    () => c.showSleepIndicator.value
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.bedtime,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Bedtime",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Obx(
                                      () => OutlinedButton(
                                        onPressed: c.useSleepWindow.value
                                            ? () async {
                                                final picked =
                                                    await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          c.bedTime.value,
                                                    );
                                                if (picked != null) {
                                                  c.bedTime.value = picked;
                                                  if (c.useSleepWindow.value) {
                                                    c.sleepHours.value =
                                                        c.calculatedSleepHours;
                                                  }
                                                }
                                              }
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              c.useSleepWindow.value
                                              ? Colors.green.shade900
                                              : Colors.grey.shade500,
                                          side: BorderSide(
                                            color: c.useSleepWindow.value
                                                ? Colors.green.shade200
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          c.bedTime.value.format(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.wb_sunny,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Wake time",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Obx(
                                      () => OutlinedButton(
                                        onPressed: c.useSleepWindow.value
                                            ? () async {
                                                final picked =
                                                    await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          c.wakeTime.value,
                                                    );
                                                if (picked != null) {
                                                  c.wakeTime.value = picked;
                                                  if (c.useSleepWindow.value) {
                                                    c.sleepHours.value =
                                                        c.calculatedSleepHours;
                                                  }
                                                }
                                              }
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              c.useSleepWindow.value
                                              ? Colors.green.shade900
                                              : Colors.grey.shade500,
                                          side: BorderSide(
                                            color: c.useSleepWindow.value
                                                ? Colors.green.shade200
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          c.wakeTime.value.format(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 8),
                  Obx(
                    () => c.showSleepIndicator.value
                        ? SizedBox.shrink()
                        : Text(
                            'Approx. ${c.sleepHours.value.toStringAsFixed(1)} hours of rest',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  Obx(
                    () => c.showSleepIndicator.value
                        ? Column(
                            children: [
                              Obx(
                                () => Row(
                                  children: [
                                    Text(
                                      c.sleepHours.value.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'hours sleep',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Slider(
                                  value: c.sleepHours.value,
                                  min: 3,
                                  max: 12,
                                  divisions: 18,
                                  label: c.sleepHours.value.toStringAsFixed(1),
                                  activeColor: Colors.green,
                                  onChanged: (value) =>
                                      c.sleepHours.value = value,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

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
                      Icon(Icons.work, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        "Work Hours",
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
                          c.workHours.value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Text(
                        " hours per day",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Obx(
                    () => Slider(
                      value: c.workHours.value,
                      min: 0,
                      max: 12,
                      divisions: 24,
                      label: c.workHours.value.toStringAsFixed(1),
                      activeColor: Colors.green,
                      onChanged: (v) => c.workHours.value = v,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

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
