import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/services/media_store.dart';
import 'package:drift/native.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';

/// PNG 1x1 trasparente valido.
final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4'
    '2mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tmp;
  late MediaStore store;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('media_test');
    // Compressor identità: nei test non c'è il plugin nativo.
    store = MediaStore(db, tmp,
        compressor: (bytes) async => Uint8List.fromList(bytes));
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('import scrive il file con path relativo e dimensioni', () async {
    final asset = await store.importBytes(_png, mimeType: 'image/png');

    expect(asset.filePath, startsWith('media/'));
    expect(File('${tmp.path}/${asset.filePath}').existsSync(), isTrue);
    expect((asset.width, asset.height), (1, 1));
    expect(asset.sha256, isNotEmpty);
  });

  test('dedup: la stessa foto non viene duplicata', () async {
    final a = await store.importBytes(_png);
    final b = await store.importBytes(_png);

    expect(b.id, a.id);
    expect((await db.select(db.mediaAssets).get()).length, 1);
  });

  test('fileFor risolve il path assoluto', () async {
    final asset = await store.importBytes(_png);
    final file = await store.fileFor(asset.id);
    expect(file!.existsSync(), isTrue);
    expect(await store.fileFor('inesistente'), isNull);
  });

  test('fallback Dart puro: niente EXIF/GPS, lato corto ridotto a 1024',
      () {
    final photo = img.Image(width: 3000, height: 2000);
    photo.exif.imageIfd['Model'] = img.IfdValueAscii('Telefono');
    photo.exif.gpsIfd['GPSLatitudeRef'] = img.IfdValueAscii('N');
    final withGps = img.encodeJpg(photo);
    expect(img.decodeJpg(withGps)!.exif.gpsIfd.isEmpty, isFalse);

    final out = img.decodeJpg(stripAndResizeJpeg(withGps))!;
    expect(out.exif.gpsIfd.isEmpty, isTrue);
    expect(out.exif.imageIfd.isEmpty, isTrue);
    expect((out.width, out.height), (1536, 1024));
  });
}
