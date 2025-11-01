# WireGuard Flutter

Un plugin de Flutter para configurar y controlar túneles VPN de WireGuard en **Android**, con control de firewall por aplicación.

---

## Plataformas Soportadas

| Android | iOS   | macOS | Windows | Linux |
| :-----: | :---: | :---: | :-----: | :---: |
|   ✔️    |  ❌   |  ❌   |    ❌   |  ❌   |

*Esta versión de la librería ha sido refactorizada para ser exclusiva de Android.*

## Características

- Creación y gestión de túneles WireGuard.
- Comunicación entre Flutter y Android 100% tipada y segura usando **Pigeon**.
- **Modo Firewall:** Permite que solo las aplicaciones seleccionadas tengan acceso a la red.
- **Modo Split-Tunnel:** Excluye a las aplicaciones seleccionadas del túnel VPN.
- Escucha de cambios de estado de la conexión en tiempo real.
- Obtención de estadísticas de uso (Rx/Tx).

## Instalación

Añade la dependencia a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  wireguard_flutter: ^0.1.0 # Reemplaza con la versión que estés usando
```

## Uso

### 1. Obtener la instancia

Accede a la instancia del plugin a través de un singleton.

```dart
final wireguard = WireGuardFlutter.instance;
```

### 2. Inicializar

Antes de conectar, inicializa la librería con un nombre para la interfaz del túnel.

```dart
await wireguard.initialize(interfaceName: 'wg0');
```

### 3. Obtener Aplicaciones Instaladas (Opcional)

Si vas a usar el firewall o el split-tunnel, necesitarás obtener la lista de paquetes de las aplicaciones instaladas en el dispositivo.

```dart
final List<InstalledApp> apps = await wireguard.getInstalledApplications();

for (final app in apps) {
  print('App: ${app.name}, Paquete: ${app.packageName}');
  // app.icon contiene los bytes del icono para mostrar en un Image.memory
}
```

### 4. Iniciar la Conexión

Construye la configuración de la VPN usando el `WgConfigBuilder` y pásala al método `startVpn`.

```dart
// 1. Crea y configura el builder
final configBuilder = WgConfigBuilder()
    .setInterface(
      privateKey: 'YOUR_PRIVATE_KEY',
      addresses: ['10.0.0.2/32'],
      dnsServers: ['1.1.1.1'],
    )
    .addPeer(
      publicKey: 'PEER_PUBLIC_KEY',
      endpoint: 'demo.wireguard.com:51820',
      allowedIps: ['0.0.0.0/0'],
    );

// 2. (Opcional) Añade reglas de firewall
// configBuilder.setAllowedApplications(['com.android.chrome']);

// 3. Inicia la VPN
await wireguard.startVpn(
  serverAddress: 'demo.wireguard.com:51820',
  providerBundleIdentifier: 'com.tu.paquete',
  config: configBuilder.build(), // Construye el objeto de configuración
);
```

El `WgConfigBuilder` te permite configurar el firewall (lista blanca) o el split-tunneling (lista negra) de la siguiente manera:

```dart
// Modo Firewall (solo estas apps tienen red)
configBuilder.setAllowedApplications(['com.slack', 'com.google.android.gm']);

// Modo Split-Tunnel (estas apps no usan la VPN)
configBuilder.setDisallowedApplications(['com.netflix.mediaclient']);
```

### 5. Escuchar Cambios de Estado

Usa el `vpnStageSnapshot` para reaccionar a los cambios en el estado de la conexión.

```dart
wireguard.vpnStageSnapshot.listen((stage) {
  print('Nuevo estado de la VPN: $stage'); // ej. VpnStage.connected
});
```

### 6. Obtener Estadísticas

Consulta el tráfico de subida y bajada del túnel.

```dart
final Stats stats = await wireguard.getStats(tunnelName: 'wg0');
print('Bytes recibidos: ${stats.rx}');
print('Bytes transmitidos: ${stats.tx}');
```

### 7. Detener la Conexión

```dart
await wireguard.stopVpn();
```

---

*"WireGuard" is a registered trademark of Jason A. Donenfeld.*

(Refactor commit fix)