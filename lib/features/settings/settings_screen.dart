import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/services/arasaac_api.dart';
import '../../domain/profile_settings.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    Future<void> save(ProfileSettings next) => ref
        .read(profileRepoProvider)
        .updateSettings(profileId, next.toJsonString());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle(profile.displayName))),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsChildMode),
          SwitchListTile(
            title: Text(l10n.settingsVoice),
            subtitle: Text(l10n.settingsVoiceSubtitle),
            value: settings.tts,
            onChanged: (v) => save(settings.copyWith(tts: v)),
          ),
          SwitchListTile(
            title: Text(l10n.settingsSounds),
            value: settings.sounds,
            onChanged: (v) => save(settings.copyWith(sounds: v)),
          ),
          SwitchListTile(
            title: Text(l10n.settingsContrast),
            value: settings.highContrast,
            onChanged: (v) => save(settings.copyWith(highContrast: v)),
          ),
          ListTile(
            title: Text(l10n.settingsCardSize),
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
          ListTile(
            title: Text(l10n.settingsTimer),
            subtitle: Text(l10n.settingsTimerSubtitle),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'linear', label: Text(l10n.settingsBar)),
                ButtonSegment(value: 'circular', label: Text(l10n.settingsRing)),
              ],
              selected: {settings.timerStyle},
              onSelectionChanged: (s) =>
                  save(settings.copyWith(timerStyle: s.first)),
            ),
          ),
          ListTile(
            title: Text(l10n.settingsTimeline),
            subtitle: Text(l10n.settingsTimelineSubtitle),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'remaining', label: Text(l10n.settingsRemaining)),
                ButtonSegment(value: 'history', label: Text(l10n.settingsHistory)),
              ],
              selected: {settings.timelineMode},
              onSelectionChanged: (s) =>
                  save(settings.copyWith(timelineMode: s.first)),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.settingsShowTimes),
            subtitle: Text(l10n.settingsShowTimesSubtitle),
            value: settings.showTimes,
            onChanged: (v) => save(settings.copyWith(showTimes: v)),
          ),
          SwitchListTile(
            title: Text(l10n.settingsShowBadges),
            subtitle: Text(l10n.settingsShowBadgesSubtitle),
            value: settings.showBadges,
            onChanged: (v) => save(settings.copyWith(showBadges: v)),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsInfo),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacy),
            subtitle: Text(l10n.settingsPrivacySubtitle),
            onTap: () => _showInfo(
              context,
                l10n.settingsPrivacy,
                l10n.settingsPrivacyBody,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(l10n.settingsCredits),
            subtitle: Text(l10n.settingsCreditsSubtitle),
            onTap: () => _showInfo(
              context,
                l10n.settingsCredits,
                l10n.settingsCreditsBody(arasaacAttribution),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.settingsLicense),
            subtitle: Text(l10n.settingsLicenseSubtitle),
            onTap: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(l10n.settingsSourceTitle),
                content: Text(
                  l10n.settingsSourceBody,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(l10n.settingsClose),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l10n.settingsOpenGithub),
                    onPressed: () => launchUrl(
                      Uri.parse(
                          'https://github.com/dadebertolino/Agenda-Visiva'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsAuthor),
            subtitle: Text(l10n.settingsAuthorBody),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsVersion),
            subtitle: const Text(K.appVersion),
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
            child: Text(AppLocalizations.of(context)!.settingsClose),
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
