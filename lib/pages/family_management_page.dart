import 'package:flutter/material.dart';
import 'package:milk_app/models/family_milk_model.dart';
import 'package:milk_app/services/family_management_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyManagementPage extends StatefulWidget {
  const FamilyManagementPage({super.key});

  @override
  State<FamilyManagementPage> createState() => _FamilyManagementPageState();
}

class _FamilyManagementPageState extends State<FamilyManagementPage> {
  final FamilyService _familyService = FamilyService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Familias'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<FamilyMilkModel>>(
          stream: _familyService.getFamily(_currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar las familias'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No tienes familias registradas'));
            } else {
              final families = snapshot.data!;
              return ListView.builder(
                itemCount: families.length,
                itemBuilder: (context, index) {
                  final family = families[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(family.familyName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditFamilyDialog(context, family);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.blue),
                            onPressed: () {
                              _showDeleteFamilyDialog(context, family);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFamilyDialog(context);
        },
        child: const Text('Agregar Familia'),
      ),
    );
  }

  // Agregar familia
  void _showFamilyDialog(BuildContext context) {
    final TextEditingController familyNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Familia'),
        content: TextField(
          controller: familyNameController,
          decoration: const InputDecoration(labelText: 'Nombre de la familia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final String familyName = familyNameController.text.trim();
              if (familyName.isNotEmpty) {
                final newFamily = FamilyMilkModel(
                  familyId: DateTime.now().millisecondsSinceEpoch.toString(),
                  familyName: familyName,
                );
                _familyService.addFamily(_currentUser!.uid, newFamily);
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  // Editar familia
  void _showEditFamilyDialog(BuildContext context, FamilyMilkModel family) {
    final TextEditingController familyNameController =
        TextEditingController(text: family.familyName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Familia'),
        content: TextField(
          controller: familyNameController,
          decoration: const InputDecoration(labelText: 'Nombre de la familia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final String updateName = familyNameController.text.trim();
              if (updateName.isNotEmpty) {
                final updateFamily = FamilyMilkModel(
                  familyId: family.familyId,
                  familyName: updateName,
                );
                _familyService.editFamily(_currentUser!.uid, updateFamily);
                Navigator.pop(context);
              }
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  // Eliminar familia
  void _showDeleteFamilyDialog(BuildContext context, FamilyMilkModel family) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Familia'),
        content: Text('¿Estás seguro de eliminar "${family.familyName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _familyService.deleteFamily(_currentUser!.uid, family.familyId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}