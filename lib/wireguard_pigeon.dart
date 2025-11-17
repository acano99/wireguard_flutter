import 'package:wireguard_flutter/wireguard_pigeon.dart';
import 'package:pigeon/pigeon.dart';

// WireGuard Tunnel Config iOS
class TunnelConfig {
  String? name;
  String? interfacePrivateKey;
  String? interfaceAddress;
  String? peerPublicKey;
  String? peerEndpoint;
  String? peerAllowedIps;
  int? peerPersistentKeepalive;
}

enum TunnelState {
  down,
  up,
}

@HostApi()
abstract class WireGuardHostApis {
  void applyConfig(TunnelConfig config);
  TunnelState getState(String name);
  void up(String name);
  void down(String name);
}

final _wg = WireGuardHostApis();
Future<void> startTunnel(TunnelConfig config) async {
  await _wg.applyConfig(config);
  await _wg.up(config.name!);
}

Future<void> stopTunnel(TunnelConfig config) async {
  await _wg.down(config.name!);
}

Future<TunnelState> stateOf(String name) => _wg.getState(name);
