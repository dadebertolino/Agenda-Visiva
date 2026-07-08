import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/tables.dart';
import '../../data/services/arasaac_api.dart';
import '../builtin_icons.dart';
import '../providers.dart';

/// Rendering unificato di un pittogramma (arasaac | photo | builtin).
/// Per photo il ref è l'id del MediaAsset, risolto via provider.
class PictogramThumb extends ConsumerWidget {
  const PictogramThumb({
    super.key,
    required this.type,
    required this.pictogramRef,
    this.size = 44,
  });

  final PictogramType type;
  final String pictogramRef;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget child = switch (type) {
      PictogramType.builtin => Icon(
          builtinIcons[pictogramRef] ?? Icons.image,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      PictogramType.arasaac => CachedNetworkImage(
          imageUrl: ArasaacApi.imageUrl(int.parse(pictogramRef)),
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      PictogramType.photo => _PhotoThumb(assetId: pictogramRef),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _PhotoThumb extends ConsumerWidget {
  const _PhotoThumb({required this.assetId});
  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(photoFileProvider(assetId)).valueOrNull;
    if (file == null) return const Icon(Icons.photo, color: Colors.grey);
    return Image.file(file, fit: BoxFit.cover);
  }
}
