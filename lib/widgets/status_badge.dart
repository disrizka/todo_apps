import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isCompleted;

  const StatusBadge({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final Color color = isCompleted ? Colors.green : Colors.orange;
    final String label = isCompleted ? 'Selesai' : 'Belum Selesai';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
