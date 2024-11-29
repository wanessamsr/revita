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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const FormPacientePage()))
        .then((_) => setState(() {
              _pacientesFuture = _fetchPacientes();
            }));
  }

  void _editPaciente(Paciente paciente) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditarPacientePage(paciente: paciente),
          ),
        )
        .then((_) => setState(() {
              _pacientesFuture = _fetchPacientes();
            }));
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addPaciente,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: "Adicionar Paciente",
      ),
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
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isWeb = constraints.maxWidth >= 600;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isWeb
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3 / 2,
                          ),
                          itemCount: pacientes.length,
                          itemBuilder: (context, index) {
                            return _PacienteCardWeb(
                              paciente: pacientes[index],
                              onEdit: () => _editPaciente(pacientes[index]),
                              onDelete: () => _deletePaciente(pacientes[index].id),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: pacientes.length,
                          itemBuilder: (context, index) {
                            return _PacienteCardMobile(
                              paciente: pacientes[index],
                            );
                          },
                        ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _PacienteCardWeb extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PacienteCardWeb({
    required this.paciente,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PacienteInfo(paciente: paciente),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: "Editar",
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Excluir",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PacienteCardMobile extends StatelessWidget {
  final Paciente paciente;

  const _PacienteCardMobile({
    required this.paciente,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _PacienteInfo(paciente: paciente),
      ),
    );
  }
}

class _PacienteInfo extends StatelessWidget {
  final Paciente paciente;

  const _PacienteInfo({
    required this.paciente,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paciente.nome,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.email, paciente.email),
        _buildInfoRow(Icons.location_city, paciente.cidade),
        _buildInfoRow(Icons.calendar_today, paciente.dataNascimento),
        _buildInfoRow(Icons.home, paciente.endereco),
        _buildInfoRow(Icons.map, paciente.cep),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
