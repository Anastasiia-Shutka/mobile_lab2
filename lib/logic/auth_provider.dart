import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  User? _currentUser;
  bool _isLoading = true;

  MqttBrowserClient? _mqttClient;
  String _boxTemp = '--';
  bool _isOnline = true;

  AuthProvider(this.repository) {
    _checkInitialConnection();
    _subscribeToConnection();
    loadUser();
  }
  String get boxTemp => _boxTemp;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  bool get isOnline => _isOnline;

  Future<void> loadUser() async {
    final hasSession = await repository.hasSession();
    if (hasSession) {
      _currentUser = await repository.getUser();
      _isOnline = await _checkRealInternet();
      if (_currentUser != null && _isOnline) _initMQTT();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isOnline = await _checkRealInternet();
    notifyListeners();

    if (!_isOnline) return false;

    User? userToAuth;
    if (email == 'anna@gmail.com' && password == '12345678') {
      userToAuth = User(name: 'Anna', email: email, password: password);
    } else {
      final savedUser = await repository.getUser();
      if (savedUser != null &&
          savedUser.email == email &&
          savedUser.password == password) {
        userToAuth = savedUser;
      }
    }

    if (userToAuth != null) {
      _currentUser = userToAuth;
      await repository.saveUser(_currentUser!);
      _initMQTT();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _mqttClient?.disconnect();
    await repository.clearData();
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isOnline = await _checkRealInternet();
    notifyListeners();

    if (!_isOnline) return false;

    final newUser = User(name: name, email: email, password: password);

    await repository.saveUser(newUser);

    _currentUser = newUser;
    _initMQTT();
    notifyListeners();
    return true;
  }

  Future<void> updateUser({
    required String newName,
    required String newEmail,
    required String newPassword,
  }) async {
    if (_currentUser != null) {
      _currentUser = User(
        name: newName,
        email: newEmail,
        password: newPassword,
      );
      await repository.saveUser(_currentUser!);
      notifyListeners();
    }
  }

  Future<void> _checkInitialConnection() async {
    _isOnline = await _checkRealInternet();
    notifyListeners();
  }

  Future<bool> _checkRealInternet() async {
  final List<ConnectivityResult> result = await 
  Connectivity().checkConnectivity();
  
  if (result.contains(ConnectivityResult.none) && result.length == 1) {
    return false;
  }

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Network check error: $e');
      return false;
    }
  }

  Future<void> _initMQTT() async {
    if (!_isOnline ||
        (_mqttClient?.connectionStatus?.state == MqttConnectionState.connected))
         {
      return;
      }
      
    _mqttClient = MqttBrowserClient(
      'wss://broker.hivemq.com/mqtt',
      'fl_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    _mqttClient!.port = 8884;

    _mqttClient!.setProtocolV311();
    _mqttClient!.websocketProtocols =
        MqttClientConstants.protocolsSingleDefault;

    _mqttClient!.keepAlivePeriod = 20;
    _mqttClient!.logging(on: true);

    try {
      debugPrint('MQTT: Attempting to connect to HiveMQ (V3.1.1)...');
      await _mqttClient!.connect();

      if (_mqttClient!.connectionStatus!.state ==
          MqttConnectionState.connected) {
        debugPrint('MQTT: CONNECTED ✅');

        _mqttClient!.subscribe('sensor/temperature', MqttQos.atMostOnce);

        _mqttClient!.updates!.listen((messages) {
          final recMess = messages[0].payload as MqttPublishMessage;
          final pt = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          debugPrint('MQTT: Data received -> $pt');
          _boxTemp = pt;
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint('MQTT: Connection error -> $e');
      _mqttClient?.disconnect();
    }
  }

  void _subscribeToConnection() {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results)
   async {
    // Перевіряємо, чи є в списку підключення (будь-що, крім none)
    if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      _isOnline = await _checkRealInternet();
    } else {
      _isOnline = false;
    }
    
    if (_isOnline && _currentUser != null) {
      _initMQTT();
    }
    notifyListeners();
    });
  }
}
