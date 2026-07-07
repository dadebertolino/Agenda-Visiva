import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants.dart';
import '../db/database.dart';
import '../db/tables.dart';
import '../repositories/agenda_repo.dart';
import 'arasaac_api.dart';
import 'media_store.dart';

/// PDF A4 ottimizzato per stampa e laminazione: card con bordo
/// tratteggiato (linea di taglio), pittogrammi ad alta risoluzione,
/// attribuzione ARASAAC obbligatoria in ogni pagina.
class PdfExportService {
  PdfExportService(this._arasaac, this._media);

  final ArasaacApi _arasaac;
  final MediaStore _media;

  Future<Uint8List> buildAgendaPdf({
    required Agenda agenda,
    required List<EditorRow> rows,
  }) async {
    final images = <String, pw.MemoryImage?>{};
    for (final row in rows) {
      images[row.item.id] = await _loadImage(row);
    }

    final doc = pw.Document(title: agenda.title);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Column(children: [
          pw.Divider(color: PdfColors.grey400, thickness: 0.5),
          pw.Text(
            arasaacAttribution,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ]),
        build: (context) => [
          pw.Text(agenda.title,
              style:
                  pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Ritaglia lungo le linee tratteggiate e plastifica.',
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < rows.length; i++)
                _card(i, rows[i], images[rows[i].item.id]),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _card(int index, EditorRow row, pw.MemoryImage? image) {
    return pw.Container(
      width: 245,
      height: 275,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
            color: PdfColors.grey500, style: pw.BorderStyle.dashed),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(children: [
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.Container(
            width: 22,
            height: 22,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
                shape: pw.BoxShape.circle, color: PdfColors.grey300),
            child: pw.Text('${index + 1}',
                style: const pw.TextStyle(fontSize: 12)),
          ),
        ),
        pw.Expanded(
          child: image != null
              ? pw.Image(image, fit: pw.BoxFit.contain)
              : _placeholder(row.activity.label),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          row.activity.label,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
          maxLines: 2,
        ),
      ]),
    );
  }

  /// Per builtin o immagini non scaricabili: iniziale in un cerchio.
  pw.Widget _placeholder(String label) {
    final initial = label.isEmpty ? '?' : label[0].toUpperCase();
    return pw.Center(
      child: pw.Container(
        width: 110,
        height: 110,
        alignment: pw.Alignment.center,
        decoration: const pw.BoxDecoration(
            shape: pw.BoxShape.circle, color: PdfColors.grey200),
        child: pw.Text(initial,
            style:
                pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold)),
      ),
    );
  }

  Future<pw.MemoryImage?> _loadImage(EditorRow row) async {
    try {
      switch (row.activity.pictogramType) {
        case PictogramType.arasaac:
          // 2500px: qualità da stampa. Cache disco: scarica una volta sola.
          final file = await _arasaac.localImage(
              int.parse(row.activity.pictogramRef),
              res: K.resPdf);
          return pw.MemoryImage(await file.readAsBytes());
        case PictogramType.photo:
          final file = await _media.fileFor(row.activity.pictogramRef);
          if (file == null) return null;
          return pw.MemoryImage(await file.readAsBytes());
        case PictogramType.builtin:
          return null;
      }
    } catch (_) {
      return null; // offline o file mancante: placeholder, mai crash
    }
  }
}
