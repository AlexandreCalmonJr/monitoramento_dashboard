// Ficheiro: lib/widgets/status_indicator.dart
// DESCRIÇÃO: Widget reutilizável para mostrar o status com cor e texto.

import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String status;

  const StatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'online':
        color = Colors.green;
        text = 'Online';
        break;
      case 'offline':
        color = Colors.orange;
        text = 'Offline';
        break;
      case 'erro':
        color = Colors.red;
        text = 'Erro';
        break;
      default:
        color = Colors.grey;
        text = 'Desconhecido';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

