import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

typedef Compressor = Future<Uint8List> Function(Uint8List input);

/// Import foto dei bambini. Punti GDPR non negoziabili:
/// - EXIF/GPS rimossi SEMPRE (keepExif: false nella compressione)
/// - ridimensionamento max 1024px (data minimization + spazio)
/// - il file resta in documents dir: mai trasmesso, mai in galleria di sistema
/// - dedup via sha256: la stessa foto non viene duplicata
class MediaStore {
  MediaStore(
    this._db,
    this._docsDir, {
    Compressor? compressor,
    ImagePicker? picker,
  })  : _compress = compressor ?? _defaultCompress,
        _picker = picker ?? ImagePicker();

  final AppDatabase _db;
  final Directory _docsDir;
  final Compressor _compress;
  final ImagePicker _picker;

  /// keepExif: false = strip metadata (posizione GPS inclusa).
  /// Su Windows il plugin nativo non esiste: stessa garanzia in Dart puro.
  static Future<Uint8List> _defaultCompress(Uint8List input) =>
      Platform.isWindows
          ? Isolate.run(() => stripAndResizeJpeg(input))
          : FlutterImageCompress.compressWithList(
              input,
              minWidth: 1024,
              minHeight: 1024,
              quality: 85,
              keepExif: false,
            );

  /// Da galleria o fotocamera. Ritorna null se l'utente annulla.
  Future<MediaAsset?> importFrom(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return null;
    return importBytes(await picked.readAsBytes());
  }

  Future<MediaAsset> importBytes(
    Uint8List original, {
    String mimeType = 'image/jpeg',
  }) async {
    final processed = await _compress(original);
    final digest = sha256.convert(processed).toString();

    final existing = await (_db.select(_db.mediaAssets)
          ..where((t) => t.sha256.equals(digest) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (existing != null) return existing;

    final id = const Uuid().v4();
    final relativePath = 'media/$id.jpg';
    final file = File('${_docsDir.path}/$relativePath');
    await file.create(recursive: true);
    await file.writeAsBytes(processed);

    final (width, height) = await _decodeDims(processed);
    await _db.into(_db.mediaAssets).insert(MediaAssetsCompanion.insert(
          id: id,
          filePath: relativePath,
          mimeType: mimeType,
          width: width,
          height: height,
          sha256: digest,
        ));

    return (_db.select(_db.mediaAssets)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Registrazione vocale già codificata (AAC/m4a) dal registratore:
  /// spostata in media/, il file temporaneo viene eliminato.
  /// L'audio non ha metadati di posizione da ripulire.
  Future<MediaAsset> importAudio(File recorded) async {
    final bytes = await recorded.readAsBytes();
    final digest = sha256.convert(bytes).toString();
    final id = const Uuid().v4();
    final relativePath = 'media/$id.m4a';
    final file = File('${_docsDir.path}/$relativePath');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    try {
      await recorded.delete();
    } catch (_) {
      // Il temporaneo lo ripulirà il sistema.
    }

    await _db.into(_db.mediaAssets).insert(MediaAssetsCompanion.insert(
          id: id,
          filePath: relativePath,
          mimeType: 'audio/mp4',
          width: 0,
          height: 0,
          sha256: digest,
        ));
    return (_db.select(_db.mediaAssets)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Minimizzazione: una registrazione sostituita o rimossa non resta sul
  /// disco se nessuna attività la usa più. Il record diventa tombstone.
  Future<void> deleteAudioIfUnused(String assetId) async {
    final users = await (_db.select(_db.activities)
          ..where((t) =>
              t.audioAssetId.equals(assetId) & t.deletedAt.isNull()))
        .get();
    if (users.isNotEmpty) return;
    final asset = await (_db.select(_db.mediaAssets)
          ..where((t) => t.id.equals(assetId)))
        .getSingleOrNull();
    if (asset == null) return;
    final file = File('${_docsDir.path}/${asset.filePath}');
    if (await file.exists()) await file.delete();
    await (_db.update(_db.mediaAssets)..where((t) => t.id.equals(assetId)))
        .write(MediaAssetsCompanion(
      deletedAt: Value(DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
      dirty: const Value(true),
    ));
  }

  /// Path assoluto di un asset (il DB conserva solo il path relativo).
  Future<File?> fileFor(String assetId) async {
    final asset = await (_db.select(_db.mediaAssets)
          ..where((t) => t.id.equals(assetId)))
        .getSingleOrNull();
    if (asset == null) return null;
    return File('${_docsDir.path}/${asset.filePath}');
  }

  Future<(int, int)> _decodeDims(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return (frame.image.width, frame.image.height);
    } catch (_) {
      return (0, 0);
    }
  }
}

/// Ricodifica JPEG senza alcun metadato (EXIF/GPS), orientamento applicato
/// ai pixel, lato corto ridotto a 1024 px come flutter_image_compress
/// (minWidth/minHeight 1024). Pura Dart: usata dove manca il plugin.
Uint8List stripAndResizeJpeg(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw const FormatException('Immagine non leggibile');
  }
  var image = img.bakeOrientation(decoded);
  final scale = math.min(image.width / 1024, image.height / 1024);
  if (scale > 1) {
    image = img.copyResize(
      image,
      width: (image.width / scale).round(),
      height: (image.height / scale).round(),
      interpolation: img.Interpolation.average,
    );
  }
  image.exif = img.ExifData();
  return img.encodeJpg(image, quality: 85);
}
