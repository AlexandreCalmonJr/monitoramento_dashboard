// Ficheiro: lib/models/device.dart
// DESCRIÇÃO: Adicionada a variável totemType que vem do servidor.

class Device {
  final String id;
  final String hostname;
  final String serialNumber;
  final String model;
  final String serviceTag;
  final String ip;
  final String location;
  final List<String> installedPrograms;
  final String printerStatus;
  final DateTime lastSeen;
  final String status;
  final String biometricReaderStatus;
  final String totemType; // NOVA VARIÁVEL ADICIONADA

  Device({
    required this.id,
    required this.hostname,
    required this.serialNumber,
    required this.model,
    required this.serviceTag,
    required this.ip,
    required this.location,
    required this.installedPrograms,
    required this.printerStatus,
    required this.lastSeen,
    required this.status,
    required this.biometricReaderStatus,
    required this.totemType, // NOVA VARIÁVEL ADICIONADA
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    // Tenta analisar a data recebida. Se falhar, usa a data/hora atual.
    DateTime parsedDate = DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now();

    return Device(
      id: json['_id'] ?? '',
      hostname: json['hostname'] ?? 'N/A',
      serialNumber: json['serialNumber'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      serviceTag: json['serviceTag'] ?? 'N/A',
      ip: json['ip'] ?? 'N/A',
      location: json['location'] ?? 'Desconhecida',
      installedPrograms: List<String>.from(json['installedPrograms'] ?? []),
      printerStatus: json['printerStatus'] ?? 'N/A',
      // A CORREÇÃO ESTÁ AQUI: Garante que a data seja convertida para o fuso horário local.
      lastSeen: parsedDate.toLocal(),
      status: json['status'] ?? 'Offline',
      biometricReaderStatus: json['biometricReaderStatus'] ?? 'N/A',
      totemType: json['totemType'] ?? 'N/A', // NOVA VARIÁVEL COM FALLBACK
    );
  }

  // Função para extrair a versão do Mozilla Firefox
  String get mozillaVersion {
    final regex = RegExp(r'Mozilla Firefox ([\d\.]+)');
    for (var program in installedPrograms) {
      final match = regex.firstMatch(program);
      if (match != null) {
        return match.group(1) ?? 'N/A';
      }
    }
    return 'N/A';
  }

  // Função para extrair a versão do Java
   String get javaVersion {
    final patterns = [
      RegExp(r'Java.*? ([\d\._]+)'),
      RegExp(r'OpenJDK.*? ([\d\._]+)'),
    ];

    for (var program in installedPrograms) {
      for (var pattern in patterns) {
        final match = pattern.firstMatch(program);
        if (match != null) {
          return match.group(1) ?? 'N/A';
        }
      }
    }
    return 'N/A';
  }

  // Lógica para extrair o status de uma impressora específica
  String _getPrinterStatusByName(String printerName) {
    if (printerStatus == 'N/A') return 'N/A';

    // Divide o texto bruto em linhas
    final lines = printerStatus.split('\n');
    
    // Encontra a primeira linha que contém o nome da impressora
    final printerLine = lines.firstWhere(
      (line) => line.toLowerCase().contains(printerName.toLowerCase()),
      orElse: () => '', // Retorna uma string vazia se não encontrar
    );

    if (printerLine.isEmpty) {
      return 'N/A'; // Impressora não encontrada
    }

    // Verifica por palavras-chave de status na linha encontrada
    if (printerLine.toLowerCase().contains('error')) {
      return 'Erro';
    }
    if (printerLine.toLowerCase().contains('offline')) {
      return 'Offline';
    }
    
    // Se a impressora foi encontrada e não tem status de erro/offline, assume-se que está online
    return 'Online';
  }

  // Getter para o status da impressora Zebra
  String get zebraStatus => _getPrinterStatusByName('zebra');

  // Getter para o status da impressora Bematech
  String get bematechStatus => _getPrinterStatusByName('bematech');
}