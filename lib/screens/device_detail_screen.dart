// Ficheiro: lib/screens/device_detail_screen.dart
// DESCRIÇÃO: Atualizado para mostrar status individual de Zebra e Bematech

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_dashboard/models/device.dart';
import 'package:monitoring_dashboard/widgets/status_indicator.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.hostname),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard(
              context,
              title: 'Informações Gerais',
              icon: Icons.computer,
              children: [
                _InfoTile(label: 'Status', valueWidget: StatusIndicator(status: device.status)),
                _InfoTile(label: 'Hostname', value: device.hostname),
                _InfoTile(label: 'Unidade / Localização', value: device.location),
                _InfoTile(label: 'Endereço IP', value: device.id),
                _InfoTile(label: 'Tipo de Totem', value: device.totemType),
                _InfoTile(label: 'Modelo', value: device.model),
                _InfoTile(label: 'Número de Série', value: device.serialNumber),
                _InfoTile(label: 'Service Tag', value: device.serviceTag),
                _InfoTile(label: 'Memória RAM', value: device.ram),
                _InfoTile(label: 'Tipo de Armazenamento', value: device.hdType),
                _InfoTile(label: 'Espaço em Disco', value: device.hdStorage),
                _InfoTile(label: 'Última Sincronização', value: DateFormat('dd/MM/yyyy HH:mm:ss').format(device.lastSeen)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Status dos Dispositivos',
              icon: Icons.devices,
              children: [
                _InfoTile(
                  label: 'Impressora Zebra',
                  valueWidget: _buildDeviceStatusChip(device.zebraStatus),
                ),
                _InfoTile(
                  label: 'Impressora Bematech',
                  valueWidget: _buildDeviceStatusChip(device.bematechStatus),
                ),
                _InfoTile(
                  label: 'Leitor Biométrico',
                  valueWidget: _buildDeviceStatusChip(device.biometricReaderStatus),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Software Instalado',
              icon: Icons.apps,
              children: [
                _InfoTile(label: 'Mozilla Firefox', value: 'Versão ${device.mozillaVersion}'),
                _InfoTile(label: 'Java', value: 'Versão ${device.javaVersion}'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Programas Instalados',
              icon: Icons.list_alt,
              children: device.installedPrograms.isNotEmpty
                  ? device.installedPrograms.map((program) => _InfoTile(label: '', value: program, isProgram: true)).toList()
                  : [const _InfoTile(label: 'Nenhum programa encontrado', value: '')],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatusChip(String status) {
    Color color;
    IconData icon;
    
    if (status.toLowerCase().contains('conectado') || status.toLowerCase().contains('online')) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (status.toLowerCase().contains('detectado')) {
      color = Colors.orange;
      icon = Icons.warning;
    } else if (status.toLowerCase().contains('não detectado') || status == 'N/A') {
      color = Colors.red;
      icon = Icons.cancel;
    } else {
      color = Colors.grey;
      icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isProgram;

  const _InfoTile({required this.label, this.value, this.valueWidget, this.isProgram = false});

  @override
  Widget build(BuildContext context) {
    if (isProgram) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 6, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value ?? '', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? 'N/A',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
          ),
        ],
      ),
    );
  }
}