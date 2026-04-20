import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellbeing/view/wellbeing_view.dart';
import '../controller/permission_controller.dart';

class PermissionScreen extends StatelessWidget {
  final controller = Get.put(PermissionController());

  PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          // 🔄 Loading
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          // ✅ Permission Granted
          if (controller.isGranted.value) {
            Future.microtask(() => Get.offAll(() => ResultScreen()));
            return const SizedBox();
          }

          // ❌ Permission Not Granted
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80),
                const SizedBox(height: 20),

                const Text(
                  "Usage Access Required",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "We need access to your app usage to analyze your wellbeing.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: controller.requestPermission,
                  child: const Text("Grant Permission"),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
