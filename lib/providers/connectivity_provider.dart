import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:propert_list/providers/user_provider.dart';

// Exposes the full list of active network interfaces.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

//Derived provider that determines if the app should act as "Online".
//This accounts for the "Offline Mode (Wi-Fi only sync)" toggle in your UI.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  final userAsync = ref.watch(userProvider); // Watch your user settings

  return connectivityAsync.when(
    data: (results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      if (!hasConnection) return false;

      // Logic for the "Offline Mode (Wi-Fi only sync)" toggle in profile & setting.jpg
      final isWifiOnlySetting =
          userAsync.maybeWhen(data: (d) => d?.isOfflineModeOnly, orElse: () => null) ?? false;
      if (isWifiOnlySetting) {
        return results.contains(ConnectivityResult.wifi);
      }

      return true;
    },
    loading: () => true, // Assume online during splash/loading to avoid flickering
    error: (_, __) => false,
  );
});