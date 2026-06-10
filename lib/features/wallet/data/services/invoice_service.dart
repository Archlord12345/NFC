import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/transaction_entity.dart';

class InvoiceService {
  static Future<void> generateAndShareInvoice(TransactionEntity transaction, bool isSender) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FACTURE DE TRANSACTION', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Type: ${transaction.type}'),
              pw.Text('Montant: ${transaction.montant.toString()} XAF'),
              pw.Text('Date: ${transaction.dateCree}'),
              pw.Text('Rôle: ${isSender ? "Émetteur" : "Récepteur"}'),
              pw.Text('ID Transaction: ${transaction.id}'),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/facture_${transaction.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Voici votre facture de transaction.');
  }
}
