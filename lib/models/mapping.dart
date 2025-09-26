// Ficheiro: lib/models/mapping.dart
// DESCRIÇÃO: Corrigido o erro 'null is not a subtype of string' ao adicionar fallbacks.

class Mapping {
  final String id;
  final String location;
  final String ipStart;
  final String ipEnd;

  Mapping({
    required this.id,
    required this.location,
    required this.ipStart,
    required this.ipEnd,
  });

  // A CORREÇÃO ESTÁ AQUI: Adicionamos '??' para fornecer um valor padrão ('N/A' ou '')
  // caso o campo venha nulo do servidor. Isso evita o erro.
  factory Mapping.fromJson(Map<String, dynamic> json) {
    return Mapping(
      id: json['_id'] ?? '',
      location: json['location'] ?? 'N/A',
      ipStart: json['ipStart'] ?? 'N/A',
      ipEnd: json['ipEnd'] ?? 'N/A',
    );
  }
}

