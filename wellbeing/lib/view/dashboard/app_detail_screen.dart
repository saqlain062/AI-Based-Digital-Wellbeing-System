import 'package:flutter/material.dart';

class AppDetailScreen extends StatelessWidget {
  const AppDetailScreen({
    super.key,
    required this.appName,
    required this.category,
    required this.usageHours,
  });

  final String appName;
  final String category;
  final double usageHours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildMetric('Today’s usage', '${usageHours.toStringAsFixed(2)}h'),
            const SizedBox(height: 16),
            _buildMetric('Weekly trend', '1h 24m average'),
            const SizedBox(height: 16),
            _buildMetric('Session history', '5 sessions'),
            const SizedBox(height: 24),
            const Text(
              'Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSession('9:24 AM', '12m'),
            _buildSession('11:45 AM', '8m'),
            _buildSession('2:15 PM', '23m'),
            _buildSession('5:30 PM', '18m'),
            _buildSession('8:45 PM', '31m'),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '💡 Suggestion\nYou use this app most between 8-10 PM. Try setting a reminder to wind down earlier.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSession(String time, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(time), Text(duration)],
      ),
    );
  }
}
