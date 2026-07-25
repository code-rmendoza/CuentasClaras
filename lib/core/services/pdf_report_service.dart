import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/database/app_database.dart';
import '../../shared/providers/business_profile_provider.dart';

class PdfReportService {
  PdfReportService._();
  static final PdfReportService instance = PdfReportService._();

  /// Genera un documento PDF profesional con el Estado de Cuenta del Cliente.
  Future<Uint8List> buildClientStatementPdf({
    required BusinessProfile profile,
    required Client client,
    required List<Debt> debts,
    required List<Payment> payments,
  }) async {
    final pdf = pw.Document();

    int totalDebtCents = 0;
    for (final d in debts) {
      if (!d.isPaid) totalDebtCents += d.amount;
    }

    final dateStr = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    profile.businessName.isNotEmpty ? profile.businessName : 'CuentasClaras Mini ERP',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  if (profile.ownerName.isNotEmpty) pw.Text('Propietario: ${profile.ownerName}'),
                  if (profile.phone.isNotEmpty) pw.Text('Teléfono: ${profile.phone}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'ESTADO DE CUENTA',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                  pw.Text('Fecha: $dateStr'),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 1, height: 20),

          // Client Details
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Cliente: ${client.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (client.phone != null) pw.Text('Contacto: ${client.phone}'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Debts Section
          pw.Text('Detalle de Cuentas por Cobrar (Fiados):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (debts.isEmpty)
            pw.Text('No hay cuentas registradas.')
          else
            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'Descripción', 'Monto Original', 'Estado'],
              data: debts.map((d) {
                final dDate = DateFormat('dd/MM/yyyy').format(d.createdAt);
                final amt = '\$${(d.amount / 100.0).toStringAsFixed(2)} ${d.currency}';
                final status = d.isPaid ? 'PAGADO' : 'PENDIENTE';
                return [dDate, d.description ?? 'Sin descripción', amt, status];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
            ),

          pw.SizedBox(height: 16),

          // Payments Section
          pw.Text('Historial de Abonos Recibidos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (payments.isEmpty)
            pw.Text('No registra abonos aún.')
          else
            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'ID Fiado', 'Monto Abonado'],
              data: payments.map((p) {
                final pDate = DateFormat('dd/MM/yyyy').format(p.createdAt);
                final amt = '\$${(p.amount / 100.0).toStringAsFixed(2)} ${p.currency}';
                return [pDate, '#${p.debtId}', amt];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
            ),

          pw.Divider(thickness: 1, height: 20),

          // Total Summary
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: pw.BoxDecoration(
                color: totalDebtCents > 0 ? PdfColors.red100 : PdfColors.green100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'SALDO TOTAL PENDIENTE: \$${(totalDebtCents / 100.0).toStringAsFixed(2)} USD',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: totalDebtCents > 0 ? PdfColors.red900 : PdfColors.green900,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 30),

          // Footer
          pw.Center(
            child: pw.Text(
              profile.receiptFooter.isNotEmpty ? profile.receiptFooter : '¡Gracias por su puntualidad en los pagos!',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
