# wireguard_flutter

A flutter plugin to setup and control VPN connection via [Wireguard](https://www.wireguard.com/) tunnel.

- [Usage](#usage)
  - [Initialize](#initialize)
  - [Connect](#connect)
  - [Disconnect](#disconnect)
  - [Stage](#stage)
- [Supported Platforms](#supported-platforms)
- [FAQ & Troubleshooting](#faq--troubleshooting)

# Contributing to wireguard_flutter

Thank you for your interest in contributing to wireguard_flutter! We appreciate your help in making this project better.

Before you start contributing, please take a moment to read the following guidelines.

## How to Contribute

1. Fork the repository to your GitHub account.
2. Clone the forked repository to your local machine.
3. Create a new branch for your contribution:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Make your changes and ensure that the code follows the project's coding standards.
5. Commit your changes with a descriptive commit message:
   ```bash
   git commit -m "Add your descriptive message here"
   ```
6. Push your changes to your forked repository:
   ```bash
   git push origin feature/your-feature-name
   ```
7. Open a pull request in the original repository and provide a detailed description of your changes.


## Usage

To use this plugin, add `wireguard_flutter` or visit [Flutter Tutorial](https://flutterflux.com/).

```
flutter pub add wireguard_flutter
```

### Initialize

Initialize a wireguard instance with a valid name using `initialize`:

```dart
final wireguard = WireGuardFlutter.instance;

// initialize the interface
await wireguard.initialize(interfaceName: 'wg0');
```

and declare the `.conf` data:
```dart
const String conf = '''[Interface]
PrivateKey = 0IZmHsxiNQ54TsUs0EQ71JNsa5f70zVf1LmDvON1CXc=
Address = 10.8.0.4/32
DNS = 1.1.1.1


[Peer]
PublicKey = 6uZg6T0J1bHuEmdqPx8OmxQ2ebBJ8TnVpnCdV8jHliQ=
PresharedKey = As6JiXcYcqwjSHxSOrmQT13uGVlBG90uXZWmtaezZVs=
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 0
Endpoint = 38.180.13.85:51820''';
```

For more info on the configuration data, see [the documentation](https://man7.org/linux/man-pages/man8/wg-quick.8.html) with examples.

### Connect

After initializing, connect using `startVpn`:

```dart
await wireguard.startVpn(
  serverAddress: address, // the server address (e.g 'demo.wireguard.com:51820')
  wgQuickConfig: conf, // the quick-config file
  providerBundleIdentifier: 'com.example', // your app identifier
);
```

### Disconnect

After connecting, disconnect using `stopVpn`:

```dart
await wireguard.stopVpn();
```

### Stage

Listen to stage change using `vpnStageSnapshot`:

```dart
wireguard.vpnStageSnapshot.listen((event) {
  debugPrint("status changed $event");
});
```

Or get the current stage using `getStage`:

```dart
final stage = await wireguard.stage();
```

The available stages are:

| Code | Description |
| ---- | ----------- |
| connecting | The interface is connecting |
| connected | The interface is connected |
| disconnecting | The interface is disconnecting |
| disconnected | The interface is disconnected |
| waitingConnection | Waiting for a user interaction |
| authenticating | Authenticating with the server |
| reconnect | Reconnecting the the interface |
| noConnection | Any connection has not been made |
| preparing | Preparing to connect |
| denied | The connection has been denied by the system, usually by refused permissions |
| exiting | Exiting the interface |

## Supported Platforms

|             | Android | iOS   | macOS | Windows | Linux |
| ----------- | ------- | ----- | ----- | ------- | ----- |
| **Version** | SDK 21+ | 15.0+ | 12+   | 7+      | Any   |


### Windows

On Windows, the app must be run as administrator to be able to create and manipulate the tunnel. To debug the app, run `flutter run` from an elevated command prompt. To run the app normally, the system will request your app to be run as administrator. No code changes or external dependencies are required.

### Linux

#### Install dependencies

The required dependencies need to be installed: `wireguard` and `wireguard-tools`.

On Ubuntu/Debian, use the following command to install the dependencies:

```bash
sudo apt install wireguard wireguard-tools openresolv
```

For other Linux distros, see [this](https://www.wireguard.com/install/).

> [!NOTE]  
> 
> If `openresolv` is not installed in the system, configuration files with a DNS provided may not connect. See [this issue](#linux-error-resolvconf-command-not-found) for more information.

#### Initializing

When `wireguard.initialize` is called, the application will request your user password (`[sudo] password for <user>:`). This is necessary because wireguard must run as a root to be able to create AND manipulate the tunnels. This is true for either debug and release modes or a distributed executable.

> [!CAUTION]
>
> Do not run the app in root mode (e.g `sudo ./executable`, `sudo flutter run`), otherwise the connection will not be established.

## FAQ & Troubleshooting

### Linux error `resolvconf: command not found`

On Linux, you may receive the error `resolvconf: command not found`. This is because wireguard tried to adjust the nameserver. Make sure to install `openresolv` or not provide the "DNS" field.

### Get Stats

To obtain traffic statistics (total bytes transmitted and received) for the active tunnel, use the `getStats` method. This is useful for monitoring data usage.

### Firewall and Split-Tunneling (Android Only)

This plugin provides functionality to control which applications use the VPN tunnel on Android. You can operate in two modes: Firewall (allow-list) or Split-Tunneling (deny-list).

#### 1. Get Installed Applications

First, you need to get a list of installed applications on the device. Use the `getInstalledApplications` method:

```dart
List<InstalledApp> apps = await WireGuardFlutter.instance.getInstalledApplications();

for (final app in apps) {
  print('App Name: ${app.name}');
  print('Package Name: ${app.packageName}');
  // You can use app.icon in an Image.memory widget
}
```

#### 2. Start VPN with Application Control

The `startVpn` method has two new optional parameters: `allowedApplications` and `disallowedApplications`.

**Important:** You can only use one of these parameters at a time. Providing both will result in an error.

**Firewall Mode (Allow-list)**

Use `allowedApplications` to specify which apps are the **only ones** allowed to use the network. On Android 10 (API 29) and above, all other apps will be **blocked** from accessing the internet. On older versions, other apps will bypass the VPN and use the normal network.

```dart
await wireguard.startVpn(
  // ... other params
  allowedApplications: ['com.example.work_app', 'com.example.another_app'],
);
```

This works by adding the `IncludedApplications` key to the WireGuard configuration.

**Split-Tunneling Mode (Deny-list)**

Use `disallowedApplications` to specify which apps should **bypass** the VPN and use the normal network. All other apps will use the VPN.

```dart
await wireguard.startVpn(
  // ... other params
  disallowedApplications: ['com.example.netflix', 'com.example.bank_app'],
);
```

This works by adding the `ExcludedApplications` key to the WireGuard configuration.

If you provide neither parameter, the VPN will work as normal, tunneling traffic for all applications.

The method returns a `Future<Map<String, int>>` containing the total received bytes (key: 'rx') and total transmitted bytes (key: 'tx').

```dart
try {
  final stats = await wireguard.getStats(tunnelName: 'wg0');
  final receivedBytes = stats['rx'] ?? 0;
  final transmittedBytes = stats['tx'] ?? 0;
  
  print('Bytes Received: $receivedBytes');
  print('Bytes Transmitted: $transmittedBytes');
} catch (e) {
  print('Error getting stats: $e');
}
```

---

"WireGuard" is a registered trademark of Jason A. Donenfeld.

Fork from [mysteriumnetwork](https://github.com/mysteriumnetwork/wireguard_dart/) tunnel.

Many Thanks for [Bruno D'Luka](https://github.com/bdlukaa) for help me.
