import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../db/database.dart';

/// Risultato di ricerca ARASAAC (subset dello schema API rilevante per noi).
class ArasaacPictogram {
  const ArasaacPictogram({
    required this.id,
    required this.keyword,
    required this.sex,
    required this.violence,
  });

  final int id;
  final String keyword;
  final bool sex;
  final bool violence;

  factory ArasaacPictogram.fromJson(Map<String, dynamic> json) {
    final keywords = (json['keywords'] as List?) ?? const [];
    final first = keywords.isNotEmpty
        ? (keywords.first as Map<String, dynamic>)['keyword'] as String? ?? ''
        : '';
    return ArasaacPictogram(
      id: json['_id'] as int,
      keyword: first,
      sex: json['sex'] as bool? ?? false,
      violence: json['violence'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() =>
      {'_id': id, 'keywords': [{'keyword': keyword}], 'sex': sex, 'violence': violence};
}

/// Client API ARASAAC. La API serve SOLO per la ricerca: il download
/// immagini usa URL statici deterministici (vedi spike-arasaac-report).
class ArasaacApi {
  ArasaacApi(this._db, {http.Client? client})
      : _client = client ?? http.Client();

  static const _base = 'https://api.arasaac.org/v1';
  static const _static = 'https://static.arasaac.org/pictograms';
  static const _cacheTtl = Duration(days: 30);
  static const _userAgent = 'AgendaVisiva/0.1 (+repo github)';

  final AppDatabase _db;
  final http.Client _client;

  /// Ricerca con FILTRO BAMBINI NON DISATTIVABILE (sex/violence).
  /// Cache SQLite con TTL 30gg: offline sulle ricerche già fatte.
  Future<List<ArasaacPictogram>> search(String text, {String lang = 'it'}) async {
    final query = text.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final cached = await _readCache(query, lang);
    if (cached != null) return _childSafe(cached);

    final uri = Uri.parse(
        '$_base/pictograms/$lang/search/${Uri.encodeComponent(query)}');
    final res = await _client
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 8));

    if (res.statusCode == 404) {
      await _writeCache(query, lang, const []);
      return const [];
    }
    if (res.statusCode != 200) {
      throw ArasaacException('HTTP ${res.statusCode} per "$query"');
    }

    final list = (jsonDecode(utf8.decode(res.bodyBytes)) as List)
        .map((j) => ArasaacPictogram.fromJson(j as Map<String, dynamic>))
        .toList();
    await _writeCache(query, lang, list);
    return _childSafe(list);
  }

  /// FILTRO OBBLIGATORIO: mai esporre pittogrammi sex/violence ai bambini.
  List<ArasaacPictogram> _childSafe(List<ArasaacPictogram> input) =>
      input.where((p) => !p.sex && !p.violence).toList();

  /// URL statico deterministico: nessuna chiamata API per il download.
  /// res: 300 (thumb), 500 (UI), 2500 (PDF stampabile).
  static String imageUrl(int id, {int res = 500, bool color = true}) =>
      '$_static/$id/${id}_${color ? '' : 'nocolor_'}$res.png';

  /// PNG su disco: media/arasaac/{id}_{res}.png — cache permanente.
  Future<File> localImage(int id, {int res = 500}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/media/arasaac/${id}_$res.png');
    if (await file.exists()) return file;

    final response = await _client.get(
      Uri.parse(imageUrl(id, res: res)),
      headers: {'User-Agent': _userAgent},
    );
    if (response.statusCode != 200) {
      throw ArasaacException('Download fallito per pittogramma $id');
    }
    await file.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<List<ArasaacPictogram>?> _readCache(String query, String lang) async {
    final row = await (_db.select(_db.arasaacSearchCache)
          ..where((t) => t.query.equals(query) & t.lang.equals(lang)))
        .getSingleOrNull();
    if (row == null) return null;
    if (DateTime.now().difference(row.fetchedAt) > _cacheTtl) return null;
    return (jsonDecode(row.resultsJson) as List)
        .map((j) => ArasaacPictogram.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeCache(
      String query, String lang, List<ArasaacPictogram> results) =>
      _db.into(_db.arasaacSearchCache).insertOnConflictUpdate(
            ArasaacSearchCacheCompanion.insert(
              query: query,
              lang: lang,
              resultsJson: jsonEncode(results.map((p) => p.toJson()).toList()),
              fetchedAt: DateTime.now(),
            ),
          );
}

class ArasaacException implements Exception {
  ArasaacException(this.message);
  final String message;
  @override
  String toString() => 'ArasaacException: $message';
}

/// Attribuzione OBBLIGATORIA (CC BY-NC-SA) — mostrare in crediti e ogni PDF.
const arasaacAttribution =
    'Pittogrammi: Sergio Palao / ARASAAC (arasaac.org), '
    'Governo di Aragona, licenza CC BY-NC-SA';
