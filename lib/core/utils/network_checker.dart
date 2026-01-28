import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  // Checks if the device has any active internet connection.
  static Future<bool> isOnline() async {
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();

    // Returns true if any connection type (wifi, mobile, ethernet) is present
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Checks specifically for Wi-Fi.
  // Useful for the "Offline Mode (Wi-Fi only sync)" toggle in your Profile UI.
  static Future<bool> isWifiOnly() async {
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.wifi);
  }

  //A stream to listen for changes in connectivity.
  // Use this to trigger the "You're offline" banner seen in home.jpg.
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}