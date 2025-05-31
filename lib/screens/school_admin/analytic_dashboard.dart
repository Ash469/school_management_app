import 'package:flutter/material.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy metrics data
    final metrics = [
      {'title': 'Average Grade', 'value': 'B+'},
      {'title': 'Attendance', 'value': '92%'},
      {'title': 'Graduation Rate', 'value': '85%'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(metric['title']!),
              trailing: Text(metric['value']!),
            ),
          );
        },
      ),
    );
  }
}
