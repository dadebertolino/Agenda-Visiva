import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/services/arasaac_api.dart';
import '../../domain/profile_settings.dart';

final _profileProvider = StreamProvider.family<Profile?, String>(
    (ref, id) => ref.watch(profileRepoProvider).watchById(id));

/// Impostazioni per-profilo + sezione informazioni (privacy, crediti, licenza).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(_profileProvider(profileId)).valueOrNull;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final settings = ProfileSettings.fromJsonString(profile.settings);

    Future<void> save(ProfileSettings next) => ref
        .read(profileRepoProvider)
        .updateSettings(profileId, next.toJsonString());

    return Scaffold(
      appBar: AppBar(title: Text('Impostazioni — ${profile.displayName}')),
      body: ListView(
        children: [
          const _SectionHeader('Modalità bambino'),
          SwitchListTile(
            title: const Text('Voce (leggi le attività)'),
            subtitle: const Text('Tocca il pittogramma per ascoltare'),
            value: settings.tts,
            onChanged: (v) => save(settings.copyWith(tts: v)),
          ),
          SwitchListTile(
            title: const Text('Suoni di conferma'),
            value: settings.sounds,
            onChanged: (v) => save(settings.copyWith(sounds: v)),
          ),
          SwitchListTile(
            title: const Text('Alto contrasto'),
            value: settings.highContrast,
            onChanged: (v) => save(settings.copyWith(highContrast: v)),
          ),
          ListTile(
            title: const Text('Dimensione pittogrammi'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 's', label: Text('S')),
                ButtonSegment(value: 'm', label: Text('M')),
                ButtonSegment(value: 'l', label: Text('L')),
              ],
              selected: {settings.cardSize},
              onSelectionChanged: (s) =>
                  save(settings.copyWith(cardSize: s.first)),
            ),
          ),
          const Divider(),
          const _SectionHeader('Informazioni'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            subtitle: const Text('Tutti i dati restano su questo dispositivo'),
            onTap: () => _showInfo(
              context,
              'Privacy',
              'Agenda Visiva funziona completamente offline.\n\n'
                  'Nomi, foto e agende non lasciano mai questo dispositivo: '
                  'nessun account, nessun server, nessun tracciamento, '
                  'nessuna pubblicità.\n\n'
                  'Le foto importate vengono ridimensionate e ripulite dai '
                  'metadati (inclusa la posizione GPS).\n\n'
                  'La condivisione di un\'agenda (.agviz o PDF) avviene solo '
                  'quando la avvii tu, con gli strumenti del tuo dispositivo. '
                  'I file .agviz non contengono mai il nome del bambino.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Crediti pittogrammi'),
            subtitle: const Text('ARASAAC'),
            onTap: () => _showInfo(
              context,
              'Crediti pittogrammi',
              '$arasaacAttribution.\n\n'
                  'I pittogrammi ARASAAC sono utilizzabili solo per scopi '
                  'non commerciali e con questa attribuzione.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Licenza e codice sorgente'),
            subtitle: const Text('PolyForm Noncommercial 1.0.0'),
            onTap: () => _showInfo(
              context,
              'Licenza',
              'Il codice di Agenda Visiva è pubblico e gratuito per sempre. '
                  'L\'uso commerciale è vietato (PolyForm Noncommercial 1.0.0).\n\n'
                  'Il codice sorgente è consultabile su GitHub.',
            ),
          ),
          const ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Autore'),
            subtitle: const Text('Made by Prof. Davide Bertolino\n'
                'Per contatti: info@davidebertolino.it'),
            isThreeLine: true,
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versione'),
            subtitle: Text(K.appVersion),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
}
