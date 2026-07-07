import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../builder/agenda_editor_screen.dart';
import '../settings/settings_screen.dart';
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
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Opzioni profilo',
                        onPressed: () => _profileOptions(context, ref, p),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                ProfileAgendasScreen(profile: p)),
                      ),
                      onLongPress: () => _profileOptions(context, ref, p),
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

  Future<void> _profileOptions(
      BuildContext context, WidgetRef ref, Profile p) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rinomina'),
            onTap: () {
              Navigator.pop(sheetContext);
              _renameProfile(context, ref, p);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Elimina'),
            onTap: () {
              Navigator.pop(sheetContext);
              _deleteProfile(context, ref, p);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _renameProfile(
      BuildContext context, WidgetRef ref, Profile p) async {
    final controller = TextEditingController(text: p.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rinomina profilo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == p.displayName) return;
    await ref.read(profileRepoProvider).rename(p.id, name);
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
      appBar: AppBar(
        title: Text('Agende di ${profile.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Impostazioni',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => SettingsScreen(profileId: profile.id)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Importa agenda (.agviz)',
            onPressed: () => _importAgviz(context, ref),
          ),
        ],
      ),
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
                      onLongPress: () => _agendaOptions(context, ref, a),
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

  Future<void> _agendaOptions(
      BuildContext context, WidgetRef ref, Agenda a) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Condividi (.agviz)'),
            subtitle: const Text(
                'Se contiene foto, condividi solo con persone fidate'),
            onTap: () {
              Navigator.pop(sheetContext);
              _shareAgviz(context, ref, a);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Elimina'),
            onTap: () {
              Navigator.pop(sheetContext);
              _deleteAgenda(context, ref, a);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _shareAgviz(
      BuildContext context, WidgetRef ref, Agenda a) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = await ref.read(agvizProvider.future);
      final file = await service.exportAgenda(a.id);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Agenda "${a.title}" — apribile con Agenda Visiva',
      );
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Condivisione non riuscita: $e')));
    }
  }

  Future<void> _importAgviz(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await FilePicker.platform.pickFiles();
      final path = picked?.files.single.path;
      if (path == null) return;

      final service = await ref.read(agvizProvider.future);
      await service.importAgenda(File(path), profileId: profile.id);
      messenger.showSnackBar(
          const SnackBar(content: Text('Agenda importata')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Import non riuscito: $e')));
    }
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
