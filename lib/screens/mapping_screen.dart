// Ficheiro: lib/screens/mapping_screen.dart
// DESCRIÇÃO: A interface foi totalmente atualizada para gerir faixas de IP.

import 'package:flutter/material.dart';
import 'package:monitoring_dashboard/api/api_service.dart';
import 'package:monitoring_dashboard/models/mapping.dart';

class MappingScreen extends StatefulWidget {
  const MappingScreen({super.key});

  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Mapping>> _mappingsFuture;

  @override
  void initState() {
    super.initState();
    _loadMappings();
  }

  void _loadMappings() {
    setState(() {
      _mappingsFuture = _apiService.getMappings(context);
    });
  }

  Future<void> _showAddMappingDialog() async {
    final formKey = GlobalKey<FormState>();
    final locationController = TextEditingController();
    final ipStartController = TextEditingController();
    final ipEndController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Unidade'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Nome da Unidade'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: ipStartController,
                    decoration: const InputDecoration(labelText: 'IP Inicial da Faixa'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: ipEndController,
                    decoration: const InputDecoration(labelText: 'IP Final da Faixa'),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _apiService.createMapping(
                    context,
                    locationController.text,
                    ipStartController.text,
                    ipEndController.text,
                  ).then((_) {
                    Navigator.of(context).pop();
                    _loadMappings();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: ${error.toString()}')),
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Unidades (Faixas de IP)'),
      ),
      body: FutureBuilder<List<Mapping>>(
        future: _mappingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma unidade configurada.'));
          }
          final mappings = snapshot.data!;
          return ListView.builder(
            itemCount: mappings.length,
            itemBuilder: (context, index) {
              final mapping = mappings[index];
              return ListTile(
                title: Text(mapping.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Faixa: ${mapping.ipStart} - ${mapping.ipEnd}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _apiService.deleteMapping(context, mapping.id).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unidade eliminada com sucesso!')),
                      );
                      _loadMappings();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMappingDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Unidade'),
      ),
    );
  }
}

