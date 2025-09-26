// Ficheiro: lib/api/api_service.dart
// DESCRIÇÃO: A função createMapping foi atualizada para enviar a faixa de IP.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_dashboard/models/device.dart';
import 'package:monitoring_dashboard/models/mapping.dart';
import 'package:monitoring_dashboard/services/settings_service.dart';
import 'package:provider/provider.dart';

class ApiService {
  Future<String> _getBaseUrl(BuildContext context) async {
    final settings = Provider.of<SettingsService>(context, listen: false);
    await settings.loadSettings();
    if (settings.ip.isEmpty || settings.port.isEmpty) {
      throw Exception('Endereço do servidor não configurado. Vá para as Configurações.');
    }
    return 'http://${settings.ip}:${settings.port}/api';
  }

  Future<List<Device>> getDevices(BuildContext context) async {
    try {
      final baseUrl = await _getBaseUrl(context);
      final response = await http.get(Uri.parse('$baseUrl/devices')).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Device.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar dispositivos. Status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Não foi possível conectar ao servidor. Verifique o endereço e a conexão.');
    } on TimeoutException {
      throw Exception('A conexão com o servidor demorou muito para responder.');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Mapping>> getMappings(BuildContext context) async {
    final baseUrl = await _getBaseUrl(context);
    final response = await http.get(Uri.parse('$baseUrl/mappings'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Mapping.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar mapeamentos.');
    }
  }

  Future<Mapping> createMapping(BuildContext context, String location, String ipStart, String ipEnd) async {
    final baseUrl = await _getBaseUrl(context);
    final response = await http.post(
      Uri.parse('$baseUrl/mappings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'location': location, 'ipStart': ipStart, 'ipEnd': ipEnd}),
    );

    if (response.statusCode == 201) {
      return Mapping.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao criar mapeamento.');
    }
  }

  Future<void> deleteMapping(BuildContext context, String id) async {
    final baseUrl = await _getBaseUrl(context);
    final response = await http.delete(Uri.parse('$baseUrl/mappings/$id'));
    if (response.statusCode != 200) {
      throw Exception('Falha ao eliminar mapeamento.');
    }
  }
}

