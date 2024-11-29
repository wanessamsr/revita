import 'package:flutter/foundation.dart'; // Necessário para usar kIsWeb
import 'package:flutter/material.dart';
import 'package:revitalize_mobile/forms/form_edit_paciente.dart';
import 'package:revitalize_mobile/forms/form_paciente.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';
import 'package:revitalize_mobile/controllers/paciente.dart';
import 'package:revitalize_mobile/models/paciente.dart';

void main() => runApp(const PacientePage());

class PacientePage extends StatefulWidget {
  const PacientePage({super.key});

  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  late Future<List<Paciente>> _pacientesFuture;

  final PacienteController _pacienteController = PacienteController();

  Future<List<Paciente>> _fetchPacientes() async {
    return await _pacienteController.getPacientes();
  }

  void _deletePaciente(String id) async {
    await _pacienteController.deletePaciente(id);
    setState(() {
      _pacientesFuture = _fetchPacientes();
    });
  }

  void _addPaciente() {
    if (kIsWeb) {
      Navigator.of(context)
          .push(
              MaterialPageRoute(builder: (context) => const FormPacientePage()))
          .then((_) => setState(() {
                _pacientesFuture = _fetchPacientes();
              }));
    }
  }

  void _editPaciente(Paciente paciente) {
    if (kIsWeb) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
                builder: (context) => EditarPacientePage(paciente: paciente)),
          )
          .then((_) => setState(() {
                _pacientesFuture = _fetchPacientes();
              }));
    }
  }

  @override
  void initState() {
    super.initState();
    _pacientesFuture = _fetchPacientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Pacientes"),
      floatingActionButton: kIsWeb
          ? FloatingActionButton(
              onPressed: _addPaciente,
              backgroundColor: Colors.blue[800],
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: "Adicionar Paciente",
            )
          : null,
      body: FutureBuilder<List<Paciente>>(
        future: _pacientesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro ao carregar pacientes: ${snapshot.error}",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum paciente encontrado.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          } else {
            List<Paciente> pacientes = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: pacientes.length,
                itemBuilder: (context, index) {
                  return _buildPacienteCard(pacientes[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPacienteCard(Paciente paciente) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paciente.nome,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildPacienteInfoRow("Email", paciente.email),
            _buildPacienteInfoRow("Cidade", paciente.cidade),
            _buildPacienteInfoRow("Data de Nascimento", paciente.dataNascimento),
            if (kIsWeb) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editPaciente(paciente),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    label: const Text("Editar"),
                  ),
                  TextButton.icon(
                    onPressed: () => _deletePaciente(paciente.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Excluir"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPacienteInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
