import 'package:barbergofe/models/acne/acne_response.dart';
import 'package:flutter/material.dart';

class ResultOverallAssessment extends StatelessWidget {
  final OverallAssessment overall;

  const ResultOverallAssessment({
    super.key,
    required this.overall,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(overall.severityColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              overall.needDoctor
                  ? Icons.local_hospital
                  : overall.severity == 'healthy'
                  ? Icons.check_circle
                  : Icons.info,
              size: 48,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            overall.severityText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Recommendation
          Text(
            overall.recommendation,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (overall.needDoctor) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nên gặp bác sĩ da liễu để được tư vấn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}