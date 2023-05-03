import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

/// Convert a String to a ConnectivityResult value.
ConnectivityResult parseConnectivityResult(String state) {
  switch (state) {
    case 'bluetooth':
    case 'wifi':
    case 'ethernet':
    case 'mobile':
    case 'vpn':
    case 'other':
      return ConnectivityResult.mobile;
    case 'none':
    default:
      return ConnectivityResult.none;
  }
}
