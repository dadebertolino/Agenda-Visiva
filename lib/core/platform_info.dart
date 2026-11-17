import 'dart:io';

/// Desktop (macOS/Windows): niente fotocamera dal picker, niente vibrazione.
bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;
