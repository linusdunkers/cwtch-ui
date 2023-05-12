// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.fluttercommunity.plus.connectivity;

import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.os.Build;

/** Reports connectivity related information such as connectivity type and wifi information. */
public class Connectivity {
  static final String CONNECTIVITY_NONE = "none";
  static final String CONNECTIVITY_MOBILE = "mobile";
  private final ConnectivityManager connectivityManager;

  public Connectivity(ConnectivityManager connectivityManager) {
    this.connectivityManager = connectivityManager;
  }

  String getNetworkType() {
    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Network network = connectivityManager.getActiveNetwork();
      NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
      if (capabilities == null) {
        return CONNECTIVITY_NONE;
      }
      // Cwtch UI only needs to know if online or offline, not type
      return CONNECTIVITY_MOBILE;
    }

    return getNetworkTypeLegacy();
  }

  @SuppressWarnings("deprecation")
  private String getNetworkTypeLegacy() {
    // handle type for Android versions less than Android 6
    android.net.NetworkInfo info = connectivityManager.getActiveNetworkInfo();
    if (info == null || !info.isConnected()) {
      return CONNECTIVITY_NONE;
    }
    int type = info.getType();
    switch (type) {
      case ConnectivityManager.TYPE_BLUETOOTH:
      case ConnectivityManager.TYPE_ETHERNET:
      case ConnectivityManager.TYPE_WIFI:
      case ConnectivityManager.TYPE_WIMAX:
      case ConnectivityManager.TYPE_VPN:
      case ConnectivityManager.TYPE_MOBILE:
      case ConnectivityManager.TYPE_MOBILE_DUN:
      case ConnectivityManager.TYPE_MOBILE_HIPRI:
        return CONNECTIVITY_MOBILE;
      default:
        return CONNECTIVITY_NONE;
    }
  }

  public ConnectivityManager getConnectivityManager() {
    return connectivityManager;
  }
}