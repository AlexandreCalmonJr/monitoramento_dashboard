// Ficheiro: lib/screens/device_list_screen.dart
// DESCRIÇÃO: Adicionada a coluna "Tipo de Totem" na tabela de dispositivos.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_dashboard/api/api_service.dart';
import 'package:monitoring_dashboard/models/device.dart';
import 'package:monitoring_dashboard/screens/device_detail_screen.dart';
import 'package:monitoring_dashboard/screens/settings_screen.dart';
import 'package:monitoring_dashboard/widgets/status_indicator.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final ApiService apiService = ApiService();
  Future<List<Device>>? _devicesFuture;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) => _loadDevices());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadDevices() {
    if (mounted) {
      setState(() {
        _devicesFuture = apiService.getDevices(context);
      });
    }
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Monitoramento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _navigateToSettings,
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDevices(),
        child: FutureBuilder<List<Device>>(
          future: _devicesFuture,
          builder: (context, snapshot) {
            if (_devicesFuture == null || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildErrorWidget('Nenhum dispositivo encontrado.');
            }

            final devices = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(devices),
                  const SizedBox(height: 24),
                  _buildDeviceTableCard(devices),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            Text(
              'Erro ao Carregar Dados',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceAll("Exception: ", ""),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              onPressed: _loadDevices,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Device> devices) {
    int total = devices.length;
    int online = devices.where((d) => d.status == 'Online').length;
    int offline = devices.where((d) => d.status == 'Offline').length;
    int error = devices.where((d) => d.status == 'Erro').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _SummaryCard(title: 'Total', count: total, icon: Icons.important_devices, color: Colors.blue),
              _SummaryCard(title: 'Online', count: online, icon: Icons.check_circle, color: Colors.green),
              _SummaryCard(title: 'Offline', count: offline, icon: Icons.error, color: Colors.orange),
              _SummaryCard(title: 'Com Erro', count: error, icon: Icons.warning, color: Colors.red),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _SummaryCard(title: 'Total de Dispositivos', count: total, icon: Icons.important_devices, color: Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _SummaryCard(title: 'Online', count: online, icon: Icons.check_circle, color: Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _SummaryCard(title: 'Offline', count: offline, icon: Icons.error, color: Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _SummaryCard(title: 'Com Erro', count: error, icon: Icons.warning, color: Colors.red)),
            ],
          );
        }
      },
    );
  }

  Widget _buildDeviceTableCard(List<Device> devices) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispositivos Gerenciados (${devices.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 12.0,
                      columns: const [
                        DataColumn(label: Text('Dispositivo', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Unidade', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('IP', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tipo de Totem', style: TextStyle(fontWeight: FontWeight.bold))), // NOVA COLUNA
                        DataColumn(label: Text('Zebra', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Bematech', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Leitor Biométrico', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Firefox', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Java', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Última Sincronização', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: devices.map((device) {
                        return DataRow(
                          cells: [
                            DataCell(Text(device.hostname)),
                            DataCell(Text(device.location)),
                            DataCell(Text(device.ip)),
                            DataCell(Text(device.totemType)), // NOVA CÉLULA COM O TIPO DE TOTEM
                            DataCell(Text(device.zebraStatus)),
                            DataCell(Text(device.bematechStatus)),
                            DataCell(Text(device.biometricReaderStatus)),
                            DataCell(Text(device.mozillaVersion)),
                            DataCell(Text(device.javaVersion)),
                            DataCell(StatusIndicator(status: device.status)),
                            DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(device.lastSeen))),
                          ],
                          onSelectChanged: (isSelected) {
                            if (isSelected != null && isSelected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeviceDetailScreen(device: device),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}