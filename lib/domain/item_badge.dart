import 'dart:convert';

/// Badge "dove" / "con chi" di un AgendaItem, serializzato nei campi
/// placeJson/companionJson. Sull'item e non sull'Activity: "palestra con
/// Maria" vale per quel martedì, non per l'attività in sé.
/// Tollerante a JSON malformato: null = nessun badge.
class ItemBadge {
  const ItemBadge({required this.type, this.ref, required this.label});

  /// 'arasaac' | 'photo' | 'text'
  final String type;

  /// ID ARASAAC o UUID MediaAsset; null se type == 'text'.
  final String? ref;

  final String label;

  static ItemBadge? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final label = map['label'] as String? ?? '';
      if (label.isEmpty) return null;
      return ItemBadge(
        type: map['type'] as String? ?? 'text',
        ref: map['ref'] as String?,
        label: label,
      );
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode({
        'type': type,
        if (ref != null) 'ref': ref,
        'label': label,
      });
}
