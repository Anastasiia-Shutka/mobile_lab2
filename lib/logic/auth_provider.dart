import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  User? _currentUser;
  bool _isLoading = true;
  String _boxTemp = '--';
  bool _isOnline = true;
  MqttBrowserClient? _mqttClient;

  AuthProvider(this.repository) {
    _checkInitialConnection();
    _subscribeToConnection();
    loadUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get boxTemp => _boxTemp;

  Future<List<String>> getParcels() async {
    const cacheKey = 'cached_parcels';

    if (_isOnline) {
      debugPrint('GET https://jsonplaceholder.typicode.com/posts?_limit=5');
      try {
        final response = await http
            .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'))
            .timeout(const Duration(seconds: 5));

        debugPrint('Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List;
          final parcels = data.map((item) => 
          "Parcel: ${item['title']}").toList();

          await repository.saveData(cacheKey, jsonEncode(parcels));
          debugPrint('Local cache updated successfully');

          return parcels;
        } else {
          debugPrint('Error: Server returned status code ${response.statusCode}'
          );
        }
      } catch (e) {
        debugPrint('Network Error: $e');
      }
    }

    debugPrint('Status: Offline. Fetching data from Local Secure Storage');
    final cachedData = await repository.getData(cacheKey);
    if (cachedData != null) {
      final decoded = jsonDecode(cachedData) as List;
      debugPrint('Cache status: ${decoded.length} items retrieved');
      return decoded.cast<String>();
    }

    return ['No data available offline'];
  }

  Future<void> loadUser() async {
    final hasSession = await repository.hasSession();
    if (hasSession) {
      _currentUser = await repository.getUser();
      debugPrint('Auth: User session restored for ${_currentUser?.email}');
      _isOnline = await _checkRealInternet();
      if (_currentUser != null && _isOnline) _initMQTT();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isOnline = await _checkRealInternet();
    if (!_isOnline) {
      debugPrint('Login: Request failed - No internet');
      return false;
    }

    if (email == 'anna@gmail.com' && password == '12345678') {
      _currentUser = User(name: 'Anna', email: email, password: password);
      await repository.saveUser(_currentUser!);
      debugPrint('Login: Success. Status Code 200');
      _initMQTT();
      notifyListeners();
      return true;
    }
    debugPrint('Login: Failed. Invalid credentials');
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isOnline = await _checkRealInternet();
    if (!_isOnline) return false;

    final newUser = User(name: name, email: email, password: password);
    await repository.saveUser(newUser);
    _currentUser = newUser;
    debugPrint('Registration: Success. User data saved locally');
    _initMQTT();
    notifyListeners();
    return true;
  }

  Future<void> updateUser(
      {required String newName,
      required String newEmail,
      required String newPassword}) async {
    if (_currentUser != null) {
      _currentUser =
          User(name: newName, email: newEmail, password: newPassword);
      await repository.saveUser(_currentUser!);
      debugPrint('Profile: Data update committed to storage');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    debugPrint('Auth: Logout sequence initiated');
    _currentUser = null;
    _mqttClient?.disconnect();
    await repository.clearData();
    notifyListeners();
  }

  Future<bool> _checkRealInternet() async {
    if (kIsWeb) return true;
    try {
      final res = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'))
          .timeout(const Duration(seconds: 3));
      debugPrint('Connectivity: Internet check returned ${res.statusCode}');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _initMQTT() async {
    if (!_isOnline ||
        _mqttClient?.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    debugPrint('MQTT: Connecting to wss://broker.hivemq.com/mqtt...');
    _mqttClient = MqttBrowserClient(
      'wss://broker.hivemq.com/mqtt',
      'fl_cl_${DateTime.now().millisecondsSinceEpoch}',
    );
    _mqttClient!.port = 8884;
    _mqttClient!.setProtocolV311();
    _mqttClient!.websocketProtocols = MqttClientConstants.protocolsSingleDefault
    ;

    try {
      await _mqttClient!.connect();
      if (_mqttClient!.connectionStatus!.state == MqttConnectionState.connected)
       {
        debugPrint('MQTT: Connection established');
        _mqttClient!.subscribe('sensor/temperature', MqttQos.atMostOnce);
        _mqttClient!.updates!.listen((messages) {
          final recMess = messages[0].payload as MqttPublishMessage;
          final pt = 
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          
          debugPrint('MQTT: Received temp data: $pt'); 
          
          _boxTemp = pt;
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint('MQTT Error: $e');
      _mqttClient?.disconnect();
    }
  }

  void _subscribeToConnection() {
    Connectivity().onConnectivityChanged.listen((results) async {
      _isOnline = results.isNotEmpty && 
      !results.contains(ConnectivityResult.none);
      if (_isOnline) _isOnline = await _checkRealInternet();
      debugPrint('System: Connectivity status changed to ${_isOnline ? 
      "Online" : "Offline"}');
      if (_isOnline && _currentUser != null) _initMQTT();
      notifyListeners();
    });
  }

  Future<void> _checkInitialConnection() async {
    _isOnline = await _checkRealInternet();
    notifyListeners();
  }
}
