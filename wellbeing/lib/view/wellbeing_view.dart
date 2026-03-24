import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ai_controller.dart';

class WellbeingView extends StatelessWidget {
  final AIController controller = Get.put(AIController());

  // Helper to create input fields
  Widget _buildInputField(String label, int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (val) {
          // Update the specific feature index in the controller
          controller.liveInputs[index] = double.tryParse(val) ?? 0.0;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Digital Wellbeing")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // RISK DISPLAY
            Obx(
              () => Card(
                color: controller.riskScore.value > 0.7
                    ? Colors.red[50]
                    : Colors.green[50],
                child: ListTile(
                  title: Text(
                    "Addiction Risk: ${(controller.riskScore.value * 100).toStringAsFixed(1)}%",
                  ),
                  subtitle: Text(controller.recommendation.value),
                ),
              ),
            ),

            SizedBox(height: 20),
            Text(
              "Enter Today's Metrics:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // THE 12 FEATURES (Examples based on your map)
            _buildInputField("Age", 0, Icons.person),
            _buildInputField("Sleep Hours", 1, Icons.bed),
            _buildInputField("Social Media (Hrs)", 2, Icons.phone_android),
            _buildInputField("App Opens", 10, Icons.touch_app),

            // ... add the rest here ...
            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () => controller.runRealInference(),
              child: Obx(
                () => controller.isProcessing.value
                    ? CircularProgressIndicator()
                    : Text("Run AI Analysis"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
