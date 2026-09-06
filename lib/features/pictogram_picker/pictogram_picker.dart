import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/builtin_icons.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/db/tables.dart';
import '../../data/services/arasaac_api.dart';
import '../../l10n/app_localizations.dart';

/// Risultato della selezione nel picker.
class PictogramSelection {
  const PictogramSelection({
    required this.type,
    required this.ref,
    required this.suggestedLabel,
  });

  final PictogramType type;
  final String ref;
  final String suggestedLabel;
}

Future<PictogramSelection?> showPictogramPicker(BuildContext context) =>
    Navigator.of(context).push<PictogramSelection>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PictogramPickerScreen(),
      ),
    );

class PictogramPickerScreen extends ConsumerStatefulWidget {
  const PictogramPickerScreen({super.key});

  @override
  ConsumerState<PictogramPickerScreen> createState() =>
      _PictogramPickerScreenState();
}

class _PictogramPickerScreenState extends ConsumerState<PictogramPickerScreen> {
  Timer? _debounce;
  String _query = '';
  bool _loading = false;
  String? _error;
  List<ArasaacPictogram> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Mai una chiamata per keystroke: debounce da costanti di prodotto.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(K.searchDebounce, () => _search(value));
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    setState(() {
      _query = query;
      _error = null;
      if (query.isEmpty) {
        _results = const [];
        _loading = false;
      } else {
        _loading = true;
      }
    });
    if (query.isEmpty) return;

    try {
      final results = await ref.read(arasaacApiProvider).search(query);
      if (!mounted || query != _query) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.pickerOfflineError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pickerTitle),
          bottom: TabBar(tabs: [
            Tab(text: l10n.pickerArasaac),
            Tab(text: l10n.pickerPhoto),
            Tab(text: l10n.pickerBuiltin),
          ]),
        ),
        body: TabBarView(
          children: [
            _buildArasaacTab(),
            const _PhotoTab(),
            _BuiltinGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildArasaacTab() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.pickerSearchHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: _onQueryChanged,
          ),
        ),
        Expanded(child: _buildResults()),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            arasaacAttribution,
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_query.isEmpty) {
        return Center(
            child: Text(l10n.pickerSearchPrompt,
              style: const TextStyle(color: Colors.grey)));
    }
    if (_results.isEmpty) {
      return Center(child: Text(l10n.pickerNoResults));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final p = _results[i];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(
            context,
            PictogramSelection(
              type: PictogramType.arasaac,
              ref: p.id.toString(),
              suggestedLabel: _capitalize(p.keyword),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: ArasaacApi.imageUrl(p.id, res: K.resThumb),
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(p.keyword,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _BuiltinGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = builtinIcons.entries.toList();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(
            context,
            PictogramSelection(
              type: PictogramType.builtin,
              ref: e.key,
              suggestedLabel: e.key[0].toUpperCase() + e.key.substring(1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(e.value,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(e.key, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

/// Foto personali: restano solo sul dispositivo, EXIF/GPS rimossi.
class _PhotoTab extends ConsumerWidget {
  const _PhotoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 64)),
            icon: const Icon(Icons.photo_library),
            label: Text(l10n.pickerGallery),
            onPressed: () => _import(context, ref, ImageSource.gallery),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 64)),
            icon: const Icon(Icons.photo_camera),
            label: Text(l10n.pickerCamera),
            onPressed: () => _import(context, ref, ImageSource.camera),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.pickerPhotoPrivacy,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _import(
      BuildContext context, WidgetRef ref, ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final store = await ref.read(mediaStoreProvider.future);
      final asset = await store.importFrom(source);
      if (asset == null || !context.mounted) return;
      Navigator.pop(
        context,
        PictogramSelection(
          type: PictogramType.photo,
          ref: asset.id,
          suggestedLabel: '',
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pickerCameraError)));
    }
  }
}
