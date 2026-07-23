import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../report/data/models/report_model.dart';

class PdfExportHelper {
  static Future<void> generateAndPrintRecap({
    required List<ReportModel> reports,
    required String periodLabel,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(periodLabel),
            pw.SizedBox(height: 20),
            _buildSummary(reports),
            pw.SizedBox(height: 20),
            _buildTable(reports),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rekap_Laporan.pdf',
    );
  }

  static pw.Widget _buildHeader(String periodLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rekapitulasi Laporan Perundungan - SpeakUp',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Periode: $periodLabel',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSummary(List<ReportModel> reports) {
    int total = reports.length;
    int completed = reports.where((r) => r.status == 'completed').length;
    int processing = reports.where((r) => r.status == 'processing' || r.status == 'mediation').length;
    int rejected = reports.where((r) => r.status == 'rejected').length;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryItem('Total Kasus', total),
        _summaryItem('Diproses', processing),
        _summaryItem('Selesai', completed),
        _summaryItem('Ditolak', rejected),
      ],
    );
  }

  static pw.Widget _summaryItem(String label, int count) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text('$count', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<ReportModel> reports) {
    final headers = ['Kode Laporan', 'Tanggal', 'Kategori', 'Status'];
    
    final data = reports.map((r) {
      return [
        r.reportCode,
        r.incidentDate ?? '-',
        r.category ?? r.title,
        _formatStatus(r.status),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  static String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation':
        return 'Menunggu Validasi';
      case 'valid':
        return 'Valid';
      case 'processing':
        return 'Diproses';
      case 'mediation':
        return 'Mediasi';
      case 'follow_up':
        return 'Tindak Lanjut';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Terkirim';
    }
  }
}
