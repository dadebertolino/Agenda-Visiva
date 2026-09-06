import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/pictogram_thumb.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/board_repo.dart';
import '../../domain/profile_settings.dart';
import '../../l10n/app_localizations.dart';
import '../pictogram_picker/pictogram_picker.dart';

final boardProvider = StreamProvider.family<List<BoardRow>, String>(
    (ref, profileId) => ref.watch(boardRepoProvider).watch(profileId));

final _profileSettingsProvider =
    StreamProvider.family<ProfileSettings, String>((ref, profileId) => ref
        .watch(profileRepoProvider)
        .watchById(profileId)
        .map((p) => ProfileSettings.fromJsonString(p?.settings)));

/// Tavola bisogni — modalità bambino: tocca l'immagine, la voce parla.
/// Deliberatamente piatta: niente categorie, niente navigazione.
class BisogniScreen extends ConsumerWidget {
  const BisogniScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(boardProvider(profileId)).valueOrNull ?? [];
    final settings =
        ref.watch(_profileSettingsProvider(profileId)).valueOrNull ??
            const ProfileSettings();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                        child: Text(l10n.needsBoardTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ],
              ),
            ),
            Expanded(
              child: rows.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          l10n.needsBoardEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9 / settings.cardScale,
                      ),
                      itemCount: rows.length,
                      itemBuilder: (context, i) =>
                          _NeedCard(row: rows[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedCard extends ConsumerWidget {
  const _NeedCard({required this.row});
  final BoardRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.mediumImpact();
          // La voce è lo scopo della tavola: parla sempre.
          ref
              .read(ttsProvider)
              .speak(
              row.activity.ttsText ?? row.activity.label,
              locale: Localizations.localeOf(context).languageCode == 'en'
                ? 'en-US'
                : 'it-IT',
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => PictogramThumb(
                    type: row.activity.pictogramType,
                    pictogramRef: row.activity.pictogramRef,
                    size: c.maxHeight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(row.activity.label,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gestione tavola — modalità adulto.
class BisogniEditScreen extends ConsumerWidget {
  const BisogniEditScreen({super.key, required this.profileId});

  final String profileId;

  static const _defaults = [
    ('Acqua', 'acqua'),
    ('Bagno', 'bagno'),
    ('Aiuto', 'aiuto'),
    ('Pausa', 'pausa'),
    ('Ho fame', 'fame'),
    ('Mi fa male', 'dolore'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(boardProvider(profileId)).valueOrNull ?? [];
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.needsBoardEditTitle)),
      body: rows.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.needsBoardEmptyAdult),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(l10n.needsBoardSeed),
                    onPressed: () => _seedDefaults(ref),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                for (final r in rows)
                  ListTile(
                    leading: PictogramThumb(
                      type: r.activity.pictogramType,
                      pictogramRef: r.activity.pictogramRef,
                    ),
                    title: Text(r.activity.label),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(boardRepoProvider).remove(r.item.id),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.needsBoardAdvice,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.needsBoardAdd),
        onPressed: () => _addNeed(context, ref),
      ),
    );
  }

  Future<void> _seedDefaults(WidgetRef ref) async {
    final activities = ref.read(activityRepoProvider);
    final board = ref.read(boardRepoProvider);
    for (final (label, icon) in _defaults) {
      final activityId = await activities.create(
          label: label,
          type: PictogramType.builtin,
          pictogramRef: icon);
      await board.add(profileId: profileId, activityId: activityId);
    }
  }

  Future<void> _addNeed(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final selection = await showPictogramPicker(context);
    if (selection == null || !context.mounted) return;

    final controller = TextEditingController(text: selection.suggestedLabel);
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.needsBoardWord),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.needsBoardAdd),
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
        .read(boardRepoProvider)
        .add(profileId: profileId, activityId: activityId);
  }
}
