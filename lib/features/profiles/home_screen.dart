import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../../l10n/app_localizations.dart';
import '../builder/agenda_editor_screen.dart';
import '../comunicazione/bisogni_screen.dart';
import '../settings/settings_screen.dart';
import '../player/player_screen.dart';

final profilesProvider = StreamProvider<List<Profile>>(
    (ref) => ref.watch(profileRepoProvider).watchAll());

final profileAgendasProvider = StreamProvider.family<List<Agenda>, String>(
    (ref, profileId) =>
        ref.watch(agendaRepoProvider).watchByProfile(profileId));

String _typeLabel(AppLocalizations l10n, AgendaType type) => switch (type) {
      AgendaType.daily => l10n.agendaTypeDaily,
      AgendaType.firstThen => l10n.agendaTypeFirstThen,
      AgendaType.sequence => l10n.agendaTypeSequence,
    };

/// Home adulto: lista profili bambino.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).valueOrNull ?? [];
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.child_care, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(l10n.homeCreateFirstProfile),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.homeNewProfile),
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
                        tooltip: l10n.homeProfileOptions,
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.homeNewProfileTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.homeProfileNameLabel,
            helperText: l10n.homeProfileNameHelper,
            helperMaxLines: 2,
          ),
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.homeCreate),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(profileRepoProvider).create(displayName: name);
  }

  Future<void> _profileOptions(
      BuildContext context, WidgetRef ref, Profile p) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.homeRename),
            onTap: () {
              Navigator.pop(sheetContext);
              _renameProfile(context, ref, p);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.homeDelete),
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: p.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.homeRenameProfileTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.homeSave),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == p.displayName) return;
    await ref.read(profileRepoProvider).rename(p.id, name);
  }

  Future<void> _deleteProfile(
      BuildContext context, WidgetRef ref, Profile p) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.homeDeleteProfileQuestion(p.displayName)),
        content: Text(l10n.homeDeleteProfileBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.homeCancel)),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.homeDelete)),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeAgendasOf(profile.displayName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.homeSettings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => SettingsScreen(profileId: profile.id)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: l10n.homeImportAgenda,
            onPressed: () => _importAgviz(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: Text(l10n.homeNeeds),
              subtitle: Text(l10n.homeNeedsSubtitle),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.homeEditBoard,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          BisogniEditScreen(profileId: profile.id)),
                ),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => BisogniScreen(profileId: profile.id)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (agendas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(l10n.homeNoAgenda,
                    style: const TextStyle(color: Colors.grey)),
              ),
            )
          else
            for (final a in agendas)
              Card(
                child: ListTile(
                  title: Text(a.title),
                  subtitle: Text(_typeLabel(l10n, a.type)),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill, size: 32),
                    tooltip: l10n.homeStartChild,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => PlayerScreen(agendaId: a.id)),
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
        label: Text(l10n.homeNewAgenda),
        onPressed: () => _createAgenda(context, ref),
      ),
    );
  }

  Future<void> _createAgenda(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.homeNewAgendaTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
              labelText: l10n.homeAgendaTitleLabel,
              hintText: l10n.homeAgendaTitleHint),
          onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.homeCreate),
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
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.homeShareAgenda),
            subtitle: Text(l10n.homeSharePhotosWarning),
            onTap: () {
              Navigator.pop(sheetContext);
              _shareAgviz(context, ref, a);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.homeDeleteAgenda),
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
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = await ref.read(agvizProvider.future);
      final file = await service.exportAgenda(a.id);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.homeShareText(a.title),
      );
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.homeShareFailed('$e'))));
    }
  }

  Future<void> _importAgviz(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await FilePicker.platform.pickFiles();
      final path = picked?.files.single.path;
      if (path == null) return;

      final service = await ref.read(agvizProvider.future);
      await service.importAgenda(File(path), profileId: profile.id);
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.homeImportSuccess)));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.homeImportFailed('$e'))));
    }
  }

  Future<void> _deleteAgenda(
      BuildContext context, WidgetRef ref, Agenda a) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.homeDeleteAgendaQuestion(a.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.homeCancel)),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.homeDeleteAgenda)),
        ],
      ),
    );
    if (ok == true) await ref.read(agendaRepoProvider).softDelete(a.id);
  }
}
