import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../builder/agenda_editor_screen.dart';
import '../player/player_screen.dart';

final profilesProvider = StreamProvider<List<Profile>>(
    (ref) => ref.watch(profileRepoProvider).watchAll());

final profileAgendasProvider = StreamProvider.family<List<Agenda>, String>(
    (ref, profileId) =>
        ref.watch(agendaRepoProvider).watchByProfile(profileId));

const _typeLabels = {
  AgendaType.daily: 'Giornata',
  AgendaType.firstThen: 'Prima–Poi',
  AgendaType.sequence: 'Sequenza',
};

/// Home adulto: lista profili bambino.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Visiva')),
      body: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.child_care, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Crea il primo profilo per iniziare'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Nuovo profilo'),
                    onPressed: () => _createProfile(context, ref),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final p in profiles)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(p.displayName.isEmpty
                            ? '?'
                            : p.displayName[0].toUpperCase()),
                      ),
                      title: Text(p.displayName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                ProfileAgendasScreen(profile: p)),
                      ),
                      onLongPress: () => _deleteProfile(context, ref, p),
                    ),
                  ),
              ],
            ),
      floatingActionButton: profiles.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _createProfile(context, ref),
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _createProfile(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuovo profilo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome o soprannome',
            helperText: 'Consigliato: solo il nome, niente cognome.\n'
                'Resta solo su questo dispositivo.',
            helperMaxLines: 2,
          ),
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(profileRepoProvider).create(displayName: name);
  }

  Future<void> _deleteProfile(
      BuildContext context, WidgetRef ref, Profile p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Eliminare ${p.displayName}?'),
        content: const Text('Le sue agende non saranno più visibili.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Elimina')),
        ],
      ),
    );
    if (ok == true) await ref.read(profileRepoProvider).softDelete(p.id);
  }
}

/// Agende di un profilo: tap = editor, play = consegna al bambino.
class ProfileAgendasScreen extends ConsumerWidget {
  const ProfileAgendasScreen({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas =
        ref.watch(profileAgendasProvider(profile.id)).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Agende di ${profile.displayName}')),
      body: agendas.isEmpty
          ? const Center(
              child: Text('Nessuna agenda. Creane una con +',
                  style: TextStyle(color: Colors.grey)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final a in agendas)
                  Card(
                    child: ListTile(
                      title: Text(a.title),
                      subtitle: Text(_typeLabels[a.type] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle_fill, size: 32),
                        tooltip: 'Avvia per il bambino',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  PlayerScreen(agendaId: a.id)),
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                AgendaEditorScreen(agendaId: a.id)),
                      ),
                      onLongPress: () => _deleteAgenda(context, ref, a),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuova agenda'),
        onPressed: () => _createAgenda(context, ref),
      ),
    );
  }

  Future<void> _createAgenda(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuova agenda'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Titolo', hintText: 'Es. Routine mattina'),
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty || !context.mounted) return;

    final agendaId = await ref.read(agendaRepoProvider).create(
        profileId: profile.id, title: title, type: AgendaType.daily);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AgendaEditorScreen(agendaId: agendaId)),
    );
  }

  Future<void> _deleteAgenda(
      BuildContext context, WidgetRef ref, Agenda a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Eliminare "${a.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Elimina')),
        ],
      ),
    );
    if (ok == true) await ref.read(agendaRepoProvider).softDelete(a.id);
  }
}
