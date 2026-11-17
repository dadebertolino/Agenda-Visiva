// Genera assets/branding/icon_macos.png dal logo arrotondato: forma
// macOS (Big Sur+), corpo 824/1024 centrato su fondo trasparente.
// Uso: dart run tool/make_macos_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final logo = img.decodePng(File('assets/branding/logo.png').readAsBytesSync())!;
  final body = img.copyResize(logo,
      width: 824, height: 824, interpolation: img.Interpolation.cubic);
  final canvas = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.compositeImage(canvas, body, dstX: 100, dstY: 100);
  File('assets/branding/icon_macos.png')
      .writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('ok: assets/branding/icon_macos.png');
}
