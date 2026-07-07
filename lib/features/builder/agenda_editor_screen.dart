import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/builtin_icons.dart';
import '../../core/providers.dart';
import '../../core/widgets/pictogram_thumb.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/agenda_repo.dart';
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
                onPressed: () => _showAddSheet(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder del picker: builtin + label. Il picker ARASAAC completo
  /// è la prossima feature; l'architettura non cambia.
  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    String selectedIcon = builtinIcons.keys.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Nome attività', hintText: 'Es. Colazione'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: builtinIcons.entries
                    .map((e) => ChoiceChip(
                          avatar: Icon(e.value, size: 18),
                          label: Text(e.key),
                          selected: selectedIcon == e.key,
                          onSelected: (_) =>
                              setState(() => selectedIcon = e.key),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final label = controller.text.trim();
                  if (label.isEmpty) return;
                  final activityId =
                      await ref.read(activityRepoProvider).create(
                            label: label,
                            type: PictogramType.builtin,
                            pictogramRef: selectedIcon,
                          );
                  await ref.read(agendaRepoProvider).addItem(
                      agendaId: agendaId, activityId: activityId);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: const Text('Aggiungi'),
              ),
            ],
          ),
        ),
      ),
    );
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

    return ListTile(
      key: key,
      onLongPress: () => _pickTimer(context, repo),
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
      subtitle: timer != null ? Text('Timer: ${timer ~/ 60} min') : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => repo.removeItem(row.item.id),
      ),
    );
  }

  Future<void> _pickTimer(BuildContext context, AgendaRepo repo) async {
    final minutes = await showDialog<int?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Timer visivo'),
        children: [null, 5, 10, 15, 20]
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
