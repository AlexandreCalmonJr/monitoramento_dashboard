// Ficheiro: lib/services/settings_service.dart
// DESCRIÇÃO: Corrigido o erro 'undefined_getter' ao adicionar getters públicos para ip e port.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _ip = '';
  String _port = '';

  // A CORREÇÃO ESTÁ AQUI: Criamos "getters" públicos.
  String get ip => _ip;
  String get port => _port;

  String? get serverIp => null;

  String? get serverPort => null;

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _ip = _prefs.getString('server_ip') ?? '';
    _port = _prefs.getString('server_port') ?? '3000';
    notifyListeners();
  }

  Future<void> saveSettings(String newIp, String newPort) async {
    _ip = newIp;
    _port = newPort;
    await _prefs.setString('server_ip', _ip);
    await _prefs.setString('server_port', _port);
    notifyListeners();
  }

  void updateSettings(String text, String text2) {}
}

