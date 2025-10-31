import 'dart:typed_data';

class InstalledApp {
  const InstalledApp({
    required this.name,
    required this.packageName,
    required this.icon,
  });

  final String name;
  final String packageName;
  final Uint8List icon;
}

class Stats {
  const Stats({
    required this.rx,
    required this.tx,
  });

  final int rx;
  final int tx;
}
