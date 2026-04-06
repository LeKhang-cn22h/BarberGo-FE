import 'package:barbergofe/core/utils/acne_helpers.dart';
import 'package:barbergofe/models/acne/acne_response.dart';
import 'package:flutter/material.dart';


class ResultRegionDetails extends StatelessWidget {
  final Map<String, RegionData> regions;

  const ResultRegionDetails({
    super.key,
    required this.regions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.face, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Chi tiết theo vùng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...regions.entries.map((entry) {
            return _buildRegionItem(
              regionKey: entry.key,
              regionData: entry.value,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRegionItem({
    required String regionKey,
    required RegionData regionData,
  }) {
    final regionName = AcneHelpers.getVietnameseName(regionKey);
    final hasAcne = regionData.hasAcne;
    final color = Color(regionData.severityColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAcne ? Icons.warning : Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Region info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  regionName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  regionData.severityText,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Confidence badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              regionData.confidencePercent,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}