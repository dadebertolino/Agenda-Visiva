import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/db/tables.dart';
import '../../data/services/arasaac_api.dart';
import '../builtin_icons.dart';

/// Rendering unificato di un pittogramma (arasaac | photo | builtin).
class PictogramThumb extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
      PictogramType.photo => Image.file(File(pictogramRef), fit: BoxFit.cover),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
