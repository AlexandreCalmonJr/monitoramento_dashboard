// Ficheiro: lib/main.dart
// DESCRIÇÃO: Tema da aplicação atualizado para um design claro e profissional.

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monitoring_dashboard/screens/device_list_screen.dart';
import 'package:monitoring_dashboard/services/settings_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // Carrega as configurações antes de iniciar a app
  final settingsService = SettingsService();
  await settingsService.loadSettings();

  runApp(
    ChangeNotifierProvider(
      create: (context) => settingsService,
      child: const MonitoringDashboardApp(),
    ),
  );
}

class MonitoringDashboardApp extends StatelessWidget {
  const MonitoringDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painel de Monitoramento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF4F7FC), // Um cinza bem claro
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black54),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          color: Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFF4F7FC), // Substituído 'background' deprecado
        ),
      ),
      home: const DeviceListScreen(),
    );
  }
}