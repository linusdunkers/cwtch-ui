import 'dart:async';

import 'package:dbus/dbus.dart';

/// D-Bus interface names
const _managerInterfaceName = 'org.freedesktop.NetworkManager';

/// Overall networking states.
enum NetworkManagerState {
  unknown,
  asleep,
  disconnected,
  disconnecting,
  connecting,
  connectedLocal,
  connectedSite,
  connectedGlobal,
}

NetworkManagerState _decodeState(int value) {
  switch (value) {
    case 10:
      return NetworkManagerState.asleep;
    case 20:
      return NetworkManagerState.disconnected;
    case 30:
      return NetworkManagerState.disconnecting;
    case 40:
      return NetworkManagerState.connecting;
    case 50:
      return NetworkManagerState.connectedLocal;
    case 60:
      return NetworkManagerState.connectedSite;
    case 70:
      return NetworkManagerState.connectedGlobal;
    default:
      return NetworkManagerState.unknown;
  }
}

/// Internet connectivity states.
enum NetworkManagerConnectivityState { unknown, none, portal, limited, full }

NetworkManagerConnectivityState _decodeConnectivityState(int value) {
  switch (value) {
    case 1:
      return NetworkManagerConnectivityState.none;
    case 2:
      return NetworkManagerConnectivityState.portal;
    case 3:
      return NetworkManagerConnectivityState.limited;
    case 4:
      return NetworkManagerConnectivityState.full;
    default:
      return NetworkManagerConnectivityState.unknown;
  }
}

class _NetworkManagerInterface {
  final Map<String, DBusValue> properties;
  final propertiesChangedStreamController =
      StreamController<List<String>>.broadcast();

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChanged =>
      propertiesChangedStreamController.stream;

  _NetworkManagerInterface(this.properties);

  void updateProperties(Map<String, DBusValue> changedProperties) {
    properties.addAll(changedProperties);
    propertiesChangedStreamController.add(changedProperties.keys.toList());
  }
}

class _NetworkManagerObject extends DBusRemoteObject {
  final interfaces = <String, _NetworkManagerInterface>{};

  void updateInterfaces(
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    interfacesAndProperties.forEach((interfaceName, properties) {
      interfaces[interfaceName] = _NetworkManagerInterface(properties);
    });
  }

  /// Returns true if removing [interfaceNames] would remove all interfaces on this object.
  bool wouldRemoveAllInterfaces(List<String> interfaceNames) {
    for (var interface in interfaces.keys) {
      if (!interfaceNames.contains(interface)) {
        return false;
      }
    }
    return true;
  }

  void removeInterfaces(List<String> interfaceNames) {
    for (var interfaceName in interfaceNames) {
      interfaces.remove(interfaceName);
    }
  }

  void updateProperties(
      String interfaceName, Map<String, DBusValue> changedProperties) {
    var interface = interfaces[interfaceName];
    if (interface != null) {
      interface.updateProperties(changedProperties);
    }
  }

  /// Gets a cached property.
  DBusValue? getCachedProperty(String interfaceName, String name) {
    var interface = interfaces[interfaceName];
    if (interface == null) {
      return null;
    }
    return interface.properties[name];
  }

  /// Gets a cached boolean property, or returns null if not present or not the correct type.
  bool? getBooleanProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached unsigned 8 bit integer property, or returns null if not present or not the correct type.
  int? getByteProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('y')) {
      return null;
    }
    return (value as DBusByte).value;
  }

  /// Gets a cached signed 32 bit integer property, or returns null if not present or not the correct type.
  int? getInt32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('i')) {
      return null;
    }
    return (value as DBusInt32).value;
  }

  /// Gets a cached unsigned 32 bit integer property, or returns null if not present or not the correct type.
  int? getUint32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('u')) {
      return null;
    }
    return (value as DBusUint32).value;
  }

  /// Gets a cached signed 64 bit integer property, or returns null if not present or not the correct type.
  int? getInt64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('x')) {
      return null;
    }
    return (value as DBusInt64).value;
  }

  /// Gets a cached unsigned 64 bit integer property, or returns null if not present or not the correct type.
  int? getUint64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('t')) {
      return null;
    }
    return (value as DBusUint64).value;
  }

  /// Gets a cached string property, or returns null if not present or not the correct type.
  String? getStringProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('s')) {
      return null;
    }
    return (value as DBusString).value;
  }

  /// Gets a cached string array property, or returns null if not present or not the correct type.
  List<String>? getStringArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('as')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusString).value)
        .toList();
  }

  /// Gets a cached object path property, or returns null if not present or not the correct type.
  DBusObjectPath? getObjectPathProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('o')) {
      return null;
    }
    return (value as DBusObjectPath);
  }

  /// Gets a cached object path array property, or returns null if not present or not the correct type.
  List<DBusObjectPath>? getObjectPathArrayProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('ao')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusObjectPath))
        .toList();
  }

  /// Gets a cached list of data property, or returns null if not present or not the correct type.
  List<Map<String, dynamic>>? getDataListProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('aa{sv}')) {
      return null;
    }
    Map<String, dynamic> convertData(DBusValue value) {
      return (value as DBusDict).children.map((key, value) => MapEntry(
            (key as DBusString).value,
            (value as DBusVariant).value.toNative(),
          ));
    }

    return (value as DBusArray)
        .children
        .map((value) => convertData(value))
        .toList();
  }

  _NetworkManagerObject(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, name: 'org.freedesktop.NetworkManager', path: path) {
    updateInterfaces(interfacesAndProperties);
  }
}

/// A client that connects to NetworkManager.
class NetworkManagerClient {

  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  /// The root D-Bus NetworkManager object at path '/org/freedesktop'.
  late final DBusRemoteObjectManager _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _NetworkManagerObject>{};

  // Subscription to object manager signals.
  StreamSubscription? _objectManagerSubscription;

  /// Creates a new NetworkManager client connected to the system D-Bus.
  NetworkManagerClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.system(),
        _closeBus = bus == null {
    _root = DBusRemoteObjectManager(
      _bus,
      name: 'org.freedesktop.NetworkManager',
      path: DBusObjectPath('/org/freedesktop'),
    );
  }

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChanged =>
      _manager?.interfaces[_managerInterfaceName]
          ?.propertiesChangedStreamController.stream ??
      Stream<List<String>>.empty();

  /// Connects to the NetworkManager D-Bus objects.
  /// Must be called before accessing methods and properties.
  Future<void> connect() async {
    // Already connected
    if (_objectManagerSubscription != null) {
      return;
    }

    // Subscribe to changes
    _objectManagerSubscription = _root.signals.listen((signal) {
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          object = _NetworkManagerObject(
              _bus, signal.changedPath, signal.interfacesAndProperties);
          _objects[signal.changedPath] = object;
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          // If all the interface are removed, then this object has been removed.
          // Keep the previous values around for the client to use.
          if (object.wouldRemoveAllInterfaces(signal.interfaces)) {
            _objects.remove(signal.changedPath);
          } else {
            object.removeInterfaces(signal.interfaces);
          }
        }
      } else if (signal is DBusPropertiesChangedSignal) {
        var object = _objects[signal.path];
        if (object != null) {
          object.updateProperties(
              signal.propertiesInterface, signal.changedProperties);
        }
      }
    });

    // Find all the objects exported.
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfacesAndProperties) {
      _objects[objectPath] =
          _NetworkManagerObject(_bus, objectPath, interfacesAndProperties);
    });
  }

  /// The type of connection being used to access the network.
  String get primaryConnectionType {
    return _manager?.getStringProperty(
          _managerInterfaceName,
          'PrimaryConnectionType',
        ) ??
        '';
  }

  /// True is NetworkManager is still starting up.
  bool get startup {
    return _manager?.getBooleanProperty(_managerInterfaceName, 'Startup') ??
        false;
  }

  /// The version of NetworkManager running.
  String get version {
    return _manager?.getStringProperty(_managerInterfaceName, 'Version') ?? '';
  }

  /// The result of the last connectivity check.
  NetworkManagerConnectivityState get connectivity {
    var value =
        _manager?.getUint32Property(_managerInterfaceName, 'Connectivity') ?? 0;
    return _decodeConnectivityState(value);
  }

  /// The overall networking state.
  NetworkManagerState get state {
    var value =
        _manager?.getUint32Property(_managerInterfaceName, 'State') ?? 0;
    return _decodeState(value);
  }

  _NetworkManagerObject? get _manager =>
      _objects[DBusObjectPath('/org/freedesktop/NetworkManager')];

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    if (_objectManagerSubscription != null) {
      await _objectManagerSubscription!.cancel();
      _objectManagerSubscription = null;
    }
    if (_closeBus) {
      await _bus.close();
    }
  }
}