import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/acne/acne_response.dart';
import 'widgets/result/result_image_preview.dart';
import 'widgets/result/result_overall_assessment.dart';
import 'widgets/result/result_summary_card.dart';
import 'widgets/result/result_severity_distribution.dart';
import 'widgets/result/result_region_details.dart';
import 'widgets/result/result_advice_section.dart';
import 'widgets/result/result_action_buttons.dart';

class AcneResultScreen extends StatelessWidget {
  final AcneResponse response;
  final File capturedImage;

  const AcneResultScreen({
    Key? key,
    required this.response,
    required this.capturedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kết quả phân tích'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            ResultImagePreview(image: capturedImage),
            const SizedBox(height: 16),

            // Overall Assessment
            if (response.data?.overall != null)
              ResultOverallAssessment(overall: response.data!.overall!),
            const SizedBox(height: 16),

            // Summary Card
            if (response.data?.summary != null)
              ResultSummaryCard(summary: response.data!.summary!),
            const SizedBox(height: 16),

            // Severity Distribution
            if (response.data?.summary?.severityCount != null)
              ResultSeverityDistribution(
                severityCount: response.data!.summary!.severityCount!,
              ),
            const SizedBox(height: 16),

            // Region Details
            if (response.data?.regions != null)
              ResultRegionDetails(regions: response.data!.regions!),
            const SizedBox(height: 16),

            // Advice Section
            if (response.data?.advice != null && response.data!.advice!.isNotEmpty)
              ResultAdviceSection(advice: response.data!.advice!),
            const SizedBox(height: 16),

            // Action Buttons
            ResultActionButtons(
              response: response,
              capturedImage: capturedImage,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}