import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/providers.dart';
import '../../core/widgets/pictogram_thumb.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/agenda_repo.dart';
import '../../domain/item_badge.dart';
import '../pictogram_picker/pictogram_picker.dart';
import '../player/player_screen.dart';
import 'providers.dart';

/// Editor agenda (modalità adulto). Criterio: routine completa in <2 minuti.
class AgendaEditorScreen extends ConsumerWidget {
  const AgendaEditorScreen({super.key, required this.agendaId});

  final String agendaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agenda = ref.watch(agendaProvider(agendaId)).valueOrNull;
    final items = ref.watch(agendaItemsProvider(agendaId)).valueOrNull ?? [];
    final recents = ref.watch(recentActivitiesProvider).valueOrNull ?? [];
    final repo = ref.read(agendaRepoProvider);

    if (agenda == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(agenda.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Stampa / PDF',
            onPressed: () => _openExportSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Anteprima come bambino',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => PlayerScreen(agendaId: agendaId)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<AgendaType>(
              segments: const [
                ButtonSegment(value: AgendaType.daily, label: Text('Giornata')),
                ButtonSegment(
                    value: AgendaType.firstThen, label: Text('Prima–Poi')),
                ButtonSegment(
                    value: AgendaType.sequence, label: Text('Sequenza')),
              ],
              selected: {agenda.type},
              onSelectionChanged: (s) => repo.updateType(agendaId, s.first),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Aggiungi la prima attività',
                        style: TextStyle(color: Colors.grey)))
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final ids = items.map((r) => r.item.id).toList();
                      final moved = ids.removeAt(oldIndex);
                      ids.insert(newIndex, moved);
                      repo.reorderItems(agendaId, ids);
                    },
                    itemBuilder: (context, index) =>
                        _ItemRow(key: ValueKey(items[index].item.id),
                            row: items[index], index: index),
                  ),
          ),
          _RecentStrip(recents: recents, agendaId: agendaId),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi attività'),
                onPressed: () => _addActivity(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExportSheet(BuildContext context, WidgetRef ref) async {
    var perPage = 4;
    var layout = 'grid'; // 'grid' | 'list'
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  const Expanded(child: Text('Formato')),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'grid', label: Text('Griglia')),
                      ButtonSegment(value: 'list', label: Text('Elenco')),
                    ],
                    selected: {layout},
                    onSelectionChanged: (s) =>
                        setState(() => layout = s.first),
                  ),
                ],
              ),
            ),
            if (layout == 'grid')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    const Expanded(child: Text('Pittogrammi per pagina')),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('1')),
                        ButtonSegment(value: 2, label: Text('2')),
                        ButtonSegment(value: 4, label: Text('4')),
                      ],
                      selected: {perPage},
                      onSelectionChanged: (s) =>
                          setState(() => perPage = s.first),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Stampa'),
              subtitle: Text(layout == 'grid'
                  ? 'Ottimizzato per ritaglio e laminazione'
                  : 'Elenco della giornata con orari e caselle'),
              onTap: () {
                Navigator.pop(sheetContext);
                _exportPdf(context, ref,
                    share: false, perPage: perPage, layout: layout);
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('Condividi PDF'),
              onTap: () {
                Navigator.pop(sheetContext);
                _exportPdf(context, ref,
                    share: true, perPage: perPage, layout: layout);
              },
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref,
      {required bool share, int perPage = 4, String layout = 'grid'}) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
        const SnackBar(content: Text('Preparo il PDF…')));
    try {
      final repo = ref.read(agendaRepoProvider);
      final agenda = await repo.watchAgenda(agendaId).first;
      final rows = await repo.watchItems(agendaId).first;
      if (agenda == null || rows.isEmpty) {
        messenger.showSnackBar(const SnackBar(
            content: Text("Aggiungi almeno un'attività prima di esportare")));
        return;
      }
      final service = await ref.read(pdfExportProvider.future);
      final bytes = layout == 'list'
          ? await service.buildAgendaListPdf(agenda: agenda, rows: rows)
          : await service.buildAgendaPdf(
              agenda: agenda, rows: rows, perPage: perPage);
      messenger.hideCurrentSnackBar();

      final filename =
          '${agenda.title.replaceAll(RegExp(r"[^\w\s-]"), "")}.pdf';
      if (share) {
        await Printing.sharePdf(bytes: bytes, filename: filename);
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes);
      }
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Export non riuscito: $e')));
    }
  }

  /// Flusso: picker (ARASAAC/base) -> label prefilled -> crea e aggiungi.
  Future<void> _addActivity(BuildContext context, WidgetRef ref) async {
    final selection = await showPictogramPicker(context);
    if (selection == null || !context.mounted) return;

    final controller = TextEditingController(text: selection.suggestedLabel);
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nome attività'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
    if (label == null || label.isEmpty) return;

    final activityId = await ref.read(activityRepoProvider).create(
          label: label,
          type: selection.type,
          pictogramRef: selection.ref,
        );
    await ref
        .read(agendaRepoProvider)
        .addItem(agendaId: agendaId, activityId: activityId);
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({super.key, required this.row, required this.index});

  final EditorRow row;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(agendaRepoProvider);
    final timer = row.item.timerSeconds;
    final times = switch ((row.item.startTime, row.item.endTime)) {
      (null, null) => null,
      (final s, null) => s,
      (null, final e) => '– $e',
      (final s, final e) => '$s – $e',
    };
    final subtitle = [
      if (times != null) times,
      if (timer != null) 'Timer: ${timer ~/ 60} min',
    ].join('   ');

    return ListTile(
      key: key,
      // Il menu è raggiungibile sia col tap sull'icona ⋮ (scopribile)
      // sia col long-press (scorciatoia per chi la conosce).
      onLongPress: () => _showItemOptions(context, repo),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_indicator, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          PictogramThumb(
            type: row.activity.pictogramType,
            pictogramRef: row.activity.pictogramRef,
          ),
        ],
      ),
      title: Text(row.activity.label),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Opzioni attività',
        onPressed: () => _showItemOptions(context, repo),
      ),
    );
  }

  /// Menu opzioni item: sostituisce il long-press diretto sul timer
  /// ora che le opzioni per-item sono più di una.
  Future<void> _showItemOptions(BuildContext context, AgendaRepo repo) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.hourglass_bottom),
              title: const Text('Timer visivo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickTimer(context, repo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Orario inizio e fine'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickTimes(context, repo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: const Text('Dove e con chi'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickBadges(context, repo);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Rimuovi dall\'agenda',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(sheetContext);
                repo.removeItem(row.item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTimes(BuildContext context, AgendaRepo repo) async {
    TimeOfDay? parse(String? hhmm) {
      if (hhmm == null) return null;
      final parts = hhmm.split(':');
      return TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    if (!context.mounted) return;
    final start = await showTimePicker(
      context: context,
      helpText: 'Orario di inizio (Annulla = nessuno)',
      initialTime: parse(row.item.startTime) ?? TimeOfDay.now(),
    );
    if (!context.mounted) return;
    final end = await showTimePicker(
      context: context,
      helpText: 'Orario di fine (Annulla = nessuno)',
      initialTime: parse(row.item.endTime) ??
          start ??
          TimeOfDay.now(),
    );
    await repo.setItemTimes(
      row.item.id,
      startTime: start != null ? fmt(start) : null,
      endTime: end != null ? fmt(end) : null,
    );
  }

  /// Dialog dove/con chi: testo libero + pittogramma opzionale dal picker.
  /// Campo vuoto = badge rimosso.
  Future<void> _pickBadges(BuildContext context, AgendaRepo repo) async {
    var place = ItemBadge.fromJsonString(row.item.placeJson);
    var companion = ItemBadge.fromJsonString(row.item.companionJson);
    final placeCtrl = TextEditingController(text: place?.label ?? '');
    final companionCtrl = TextEditingController(text: companion?.label ?? '');

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Dove e con chi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _badgeField(
                context: context,
                icon: Icons.place_outlined,
                hint: 'Dove (es. Palestra)',
                controller: placeCtrl,
                badge: place,
                onPictogram: (b) => setState(() => place = b),
              ),
              const SizedBox(height: 12),
              _badgeField(
                context: context,
                icon: Icons.person_outline,
                hint: 'Con chi (es. Maria)',
                controller: companionCtrl,
                badge: companion,
                onPictogram: (b) => setState(() => companion = b),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
    if (save != true) return;

    ItemBadge? build(ItemBadge? picked, String text) {
      final label = text.trim();
      if (label.isEmpty) return null;
      // Il pittogramma scelto resta valido anche se il testo è cambiato.
      return ItemBadge(
          type: picked?.type ?? 'text', ref: picked?.ref, label: label);
    }

    await repo.setItemBadges(
      row.item.id,
      placeJson: build(place, placeCtrl.text)?.toJsonString(),
      companionJson: build(companion, companionCtrl.text)?.toJsonString(),
    );
  }

  Widget _badgeField({
    required BuildContext context,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required ItemBadge? badge,
    required ValueChanged<ItemBadge?> onPictogram,
  }) {
    return Row(
      children: [
        badge != null && badge.ref != null
            ? PictogramThumb(
                type: badge.type == 'photo'
                    ? PictogramType.photo
                    : PictogramType.arasaac,
                pictogramRef: badge.ref!,
                size: 36,
              )
            : Icon(icon, size: 36, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.image_search),
          tooltip: 'Scegli pittogramma',
          onPressed: () async {
            final sel = await showPictogramPicker(context);
            if (sel == null) return;
            if (controller.text.trim().isEmpty) {
              controller.text = sel.suggestedLabel;
            }
            onPictogram(ItemBadge(
              type: sel.type == PictogramType.photo ? 'photo' : 'arasaac',
              ref: sel.ref,
              label: sel.suggestedLabel,
            ));
          },
        ),
      ],
    );
  }

  Future<void> _pickTimer(BuildContext context, AgendaRepo repo) async {
    final minutes = await showDialog<int?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Timer visivo'),
        children: [null, 1, 2, 5, 10, 15, 20, 30, 40, 50, 60]
            .map((m) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, m ?? -1),
                  child: Text(m == null ? 'Nessuno' : '$m minuti'),
                ))
            .toList(),
      ),
    );
    if (minutes == null) return;
    await repo.setItemTimer(row.item.id, minutes == -1 ? null : minutes * 60);
  }
}

/// Striscia quick-add: le insegnanti riusano sempre le stesse attività.
class _RecentStrip extends ConsumerWidget {
  const _RecentStrip({required this.recents, required this.agendaId});

  final List<Activity> recents;
  final String agendaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recents.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final a = recents[i];
          return ActionChip(
            avatar: PictogramThumb(
                type: a.pictogramType, pictogramRef: a.pictogramRef, size: 24),
            label: Text(a.label),
            onPressed: () => ref
                .read(agendaRepoProvider)
                .addItem(agendaId: agendaId, activityId: a.id),
          );
        },
      ),
    );
  }
}
