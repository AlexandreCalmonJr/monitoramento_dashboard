// Ficheiro: lib/screens/device_list_screen.dart
// DESCRIÇÃO: Tabela ajustada para expandir e ocupar 100% da largura disponível na tela, eliminando espaços laterais.

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
  String _searchQuery = '';
  String _filterStatus = 'Todos';

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

  void _navigateToDetail(Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailScreen(device: device),
      ),
    );
  }

  List<Device> _filterDevices(List<Device> devices) {
    return devices.where((device) {
      final matchesSearch = device.hostname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          device.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          device.ip.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _filterStatus == 'Todos' || device.status == _filterStatus;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard_customize_outlined),
            SizedBox(width: 8),
            Text('Painel de Monitoramento'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadDevices,
            tooltip: 'Atualizar',
          ),
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

            final allDevices = snapshot.data!;
            final filteredDevices = _filterDevices(allDevices);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(allDevices),
                  const SizedBox(height: 24),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 16),
                  _buildDeviceDataTable(filteredDevices),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por hostname, localização ou IP...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'Todos',
                  isSelected: _filterStatus == 'Todos',
                  onSelected: () => setState(() => _filterStatus = 'Todos'),
                ),
                _FilterChip(
                  label: 'Online',
                  isSelected: _filterStatus == 'Online',
                  color: Colors.green,
                  onSelected: () => setState(() => _filterStatus = 'Online'),
                ),
                _FilterChip(
                  label: 'Offline',
                  isSelected: _filterStatus == 'Offline',
                  color: Colors.orange,
                  onSelected: () => setState(() => _filterStatus = 'Offline'),
                ),
                _FilterChip(
                  label: 'Erro',
                  isSelected: _filterStatus == 'Erro',
                  color: Colors.red,
                  onSelected: () => setState(() => _filterStatus = 'Erro'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceDataTable(List<Device> devices) {
    if (devices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum dispositivo encontrado para os filtros aplicados.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // Adicionado para garantir que o conteúdo respeite as bordas do Card
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                dataRowHeight: 60,
                columnSpacing: 40,
                headingTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('Dispositivo')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('IP')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Periféricos')),
                  DataColumn(label: Text('Software')),
                  DataColumn(label: Text('Última Sinc.')),
                ],
                rows: devices.map((device) {
                  return DataRow(
                    onSelectChanged: (_) => _navigateToDetail(device),
                    cells: [
                      DataCell(_buildDeviceHostCell(device)),
                      DataCell(StatusIndicator(status: device.status)),
                      DataCell(Text(device.ip)),
                      DataCell(Text(device.totemType)),
                      DataCell(_buildPeripheralsCell(device)),
                      DataCell(_buildSoftwareCell(device)),
                      DataCell(Text(DateFormat('dd/MM HH:mm').format(device.lastSeen))),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceHostCell(Device device) {
    return Row(
      children: [
        Icon(Icons.computer, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(device.hostname, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(device.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildPeripheralsCell(Device device) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DeviceStatusBadge(icon: Icons.local_printshop, label: 'Zebra', status: device.zebraStatus),
        const SizedBox(width: 6),
        _DeviceStatusBadge(icon: Icons.print, label: 'Bematech', status: device.bematechStatus),
        const SizedBox(width: 6),
        _DeviceStatusBadge(icon: Icons.fingerprint, label: 'Biométrico', status: device.biometricReaderStatus),
      ],
    );
  }
  
  Widget _buildSoftwareCell(Device device) {
      return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
               _SoftwareBadge(icon: Icons.language, label: 'Firefox', version: device.mozillaVersion, color: Colors.orange),
               const SizedBox(width: 6),
               _SoftwareBadge(icon: Icons.coffee, label: 'Java', version: device.javaVersion, color: Colors.blueGrey),
          ],
      );
  }


  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Colors.grey[400], size: 64),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _SummaryCard(title: 'Total', count: total, icon: Icons.devices, color: Colors.blue),
              _SummaryCard(title: 'Online', count: online, icon: Icons.check_circle, color: Colors.green),
              _SummaryCard(title: 'Offline', count: offline, icon: Icons.error, color: Colors.orange),
              _SummaryCard(title: 'Com Erro', count: error, icon: Icons.warning, color: Colors.red),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _SummaryCard(title: 'Total', count: total, icon: Icons.devices, color: Colors.blue)),
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[100],
      selectedColor: (color ?? Theme.of(context).primaryColor).withOpacity(0.2),
      checkmarkColor: color ?? Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? Theme.of(context).primaryColor) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _DeviceStatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;

  const _DeviceStatusBadge({
    required this.icon,
    required this.label,
    required this.status,
  });

  Color _getStatusColor() {
    if (status.toLowerCase().contains('conectado') || status.toLowerCase().contains('online')) {
      return Colors.green;
    } else if (status.toLowerCase().contains('detectado')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    if (status.toLowerCase().contains('conectado') || status.toLowerCase().contains('online')) {
      return Icons.check_circle;
    } else if (status.toLowerCase().contains('detectado')) {
      return Icons.warning;
    } else {
      return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Icon(statusIcon, size: 12, color: color),
        ],
      ),
    );
  }
}

class _SoftwareBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String version;
  final Color color;

  const _SoftwareBadge({
    required this.icon,
    required this.label,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isInstalled = version != 'N/A';
    final displayColor = isInstalled ? color : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: displayColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: displayColor),
          ),
          if (isInstalled) ...[
            const SizedBox(width: 4),
            Text(
              version,
              style: TextStyle(fontSize: 10, color: displayColor),
            ),
          ],
        ],
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}