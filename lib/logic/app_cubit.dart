import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';
import 'package:my_project/logic/app_state.dart';

class AppCubit extends Cubit<AppState> {
  final AuthRepository repo;
  MqttBrowserClient? _mqttClient;

  AppCubit(this.repo) : super(AppState()) {
    _initConnect();
  }

  void _initConnect() async {
    final online = await _checkRealInternet();
    emit(state.copyWith(isOnline: online));
    Connectivity().onConnectivityChanged.listen((res) async {
      final isOn = res.isNotEmpty && !res.contains(ConnectivityResult.none);
      final realOn = isOn && await _checkRealInternet();
      emit(state.copyWith(isOnline: realOn));
      if (realOn && state.user != null) _initMQTT();
    });
    loadUser();
  }

  Future<void> loadUser() async {
    if (await repo.hasSession()) {
      final user = await repo.getUser();
      emit(state.copyWith(user: user, isLoading: false));
      if (user != null && state.isOnline) _initMQTT();
      getParcels();
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getParcels() async {
    emit(state.copyWith(isParcelsLoading: true));
    const key = 'cached_parcels';
    if (state.isOnline) {
      try {
        final res = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as List;
          final p = data.map((item) => "Parcel: ${item['title']}").toList();
          await repo.saveData(key, jsonEncode(p));
          emit(state.copyWith(parcels: p, isParcelsLoading: false));
          return;
        }
      } catch (_) {}
    }
    final cached = await repo.getData(key);
    if (cached != null) {
      emit(state.copyWith(parcels: List<String>.from(jsonDecode(cached) as List)
      , isParcelsLoading: false));
    } else {
      emit(state.copyWith(parcels: ['No data available offline'], 
      isParcelsLoading: false));
    }
  }

  Future<bool> login(String e, String p) async {
    if (!state.isOnline) return false;
    if (e == 'anna@gmail.com' && p == '12345678') {
      final u = User(name: 'Anna', email: e, password: p);
      await repo.saveUser(u);
      emit(state.copyWith(user: u));
      _initMQTT();
      getParcels();
      return true;
    }
    return false;
  }

  Future<bool> register(String n, String e, String p) async {
    if (!state.isOnline) return false;
    final u = User(name: n, email: e, password: p);
    await repo.saveUser(u);
    emit(state.copyWith(user: u));
    _initMQTT();
    getParcels();
    return true;
  }

  Future<void> updateUser(String n, String e, String p) async {
    if (state.user != null) {
      final u = User(name: n, email: e, password: p);
      await repo.saveUser(u);
      emit(state.copyWith(user: u));
    }
  }

  void toggleBox() => emit(state.copyWith(isBoxOpen: !state.isBoxOpen));

  Future<void> logout() async {
    _mqttClient?.disconnect();
    await repo.clearData();
    emit(AppState(isLoading: false, isOnline: state.isOnline));
  }

  Future<bool> _checkRealInternet() async {
    if (kIsWeb) return true;
    try {
      final res = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1')).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) { return false; }
  }

  void _initMQTT() async {
    debugPrint('MQTT: Attempting to start...'); 
    
    if (!state.isOnline) {
      debugPrint('MQTT: No internet connection, aborting.');
      return;
    }
    if (_mqttClient?.connectionStatus?.state == MqttConnectionState.connected) {
      debugPrint('MQTT: Already connected.');
      return;
    }

    _mqttClient = MqttBrowserClient('wss://broker.hivemq.com/mqtt', 'fl_cl_${DateTime.now().millisecondsSinceEpoch}')
      ..port = 8884
      ..setProtocolV311();
      
    try {
      debugPrint('MQTT: Connecting to HiveMQ broker...');
      await _mqttClient!.connect();
      
      if (_mqttClient!.connectionStatus!.state == MqttConnectionState.connected)
       {
        debugPrint('MQTT: Successfully connected!');
        
        const myTopic = 'smart_post/temp';
        
        _mqttClient!.subscribe(myTopic, MqttQos.atMostOnce);
        debugPrint('MQTT: Subscribed to topic: $myTopic');
        
        _mqttClient!.updates!.listen((msgs) {
          final pt = MqttPublishPayload.bytesToStringAsString(
            (msgs[0].payload as MqttPublishMessage).payload.message);
          debugPrint('MQTT: Received temperature: $pt'); 
          emit(state.copyWith(boxTemp: pt));
        });
      }
    } catch (e) { 
      debugPrint('MQTT: Connection error: $e');
      _mqttClient?.disconnect(); 
    }
  }
}
