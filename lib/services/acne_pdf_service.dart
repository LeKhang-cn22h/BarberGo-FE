// lib/services/acne_pdf_service.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/acne/acne_response.dart';

class AcnePdfService {

  /// Xuất kết quả dưới dạng PDF
  static Future<String> exportToPdf({
    required AcneResponse response,
    required File image,
  }) async {
    try {
      print('📄 [PDF] Starting PDF export...');

      // Tạo PDF document
      final pdf = pw.Document();

      // Load ảnh
      final imageBytes = await image.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      // Tạo nội dung PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 20),

            // Ảnh
            pw.Center(
              child: pw.Container(
                width: 300,
                height: 300,
                child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
              ),
            ),
            pw.SizedBox(height: 20),

            // Overall Assessment
            if (response.data?.overall != null)
              _buildOverallSection(response.data!.overall!),

            pw.SizedBox(height: 20),

            // Summary
            if (response.data?.summary != null)
              _buildSummarySection(response.data!.summary!),

            pw.SizedBox(height: 20),

            // Regions
            if (response.data?.regions != null)
              _buildRegionsSection(response.data!.regions!),

            pw.SizedBox(height: 20),

            // Advice
            if (response.data?.advice != null)
              _buildAdviceSection(response.data!.advice!),

            // Footer
            pw.SizedBox(height: 30),
            _buildFooter(),
          ],
        ),
      );

      // Lưu file
      final directory = await getApplicationDocumentsDirectory();
      final pdfFolder = Directory('${directory.path}/acne_pdfs');

      if (!await pdfFolder.exists()) {
        await pdfFolder.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final pdfPath = '${pdfFolder.path}/acne_report_$timestamp.pdf';

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      print('✅ [PDF] Saved: $pdfPath');
      return pdfPath;

    } catch (e) {
      print('❌ [PDF] Error: $e');
      rethrow;
    }
  }

  // ==================== PDF SECTIONS ====================

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'KẾT QUẢ PHÂN TÍCH MỤN',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildOverallSection(OverallAssessment overall) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _getPdfColor(overall.severity),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ĐÁNH GIÁ TỔNG QUÁT',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Mức độ: ${overall.severityText}',
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            overall.recommendation,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
          if (overall.needDoctor)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                '⚠️ Nên gặp bác sĩ da liễu để được tư vấn',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(AcneSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'THỐNG KÊ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tổng vùng', '${summary.totalRegions}'),
              _buildStatItem('Có mụn', '${summary.acneRegions}'),
              _buildStatItem('Sạch', '${summary.clearRegions}'),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Tỷ lệ có mụn: ${summary.acnePercentage.toStringAsFixed(1)}%',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Độ tin cậy: ${(summary.averageConfidence * 100).toStringAsFixed(1)}%',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRegionsSection(Map<String, RegionData> regions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CHI TIẾT THEO VÙNG',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        ...regions.entries.map((entry) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _getVietnameseName(entry.key),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      entry.value.severityText,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      entry.value.confidencePercent,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildAdviceSection(List<AdviceItem> advice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'LỜI KHUYÊN CHĂM SÓC',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        ...advice.map((item) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${item.zone} - ${item.severityText}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...item.tips.map((tip) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                        pw.Expanded(
                          child: pw.Text(
                            tip,
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          'Lưu ý: Đây chỉ là công cụ hỗ trợ. Vui lòng tham khảo ý kiến bác sĩ da liễu.',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // ==================== HELPERS ====================

  static PdfColor _getPdfColor(String severity) {
    const map = {
      'severe': PdfColors.red700,
      'moderate': PdfColors.orange700,
      'mild': PdfColors.yellow700,
      'none': PdfColors.green700,
      'healthy': PdfColors.green700,
    };
    return map[severity] ?? PdfColors.grey;
  }

  static String _getVietnameseName(String key) {
    const map = {
      'forehead': 'Trán',
      'nose': 'Mũi',
      'cheek_left': 'Má trái',
      'cheek_right': 'Má phải',
      'chin': 'Cằm',
    };
    return map[key] ?? key;
  }
}