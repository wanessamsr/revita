import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/forms/form_prontuario.dart';
import 'package:revitalize_mobile/pages/prontuario_by.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart'; // AppBar customizado

class ProntuarioPacientePage extends StatefulWidget {
  @override
  _ProntuarioPacientePageState createState() => _ProntuarioPacientePageState();
}

class _ProntuarioPacientePageState extends State<ProntuarioPacientePage> {
  final ProntuarioController _prontuarioController = ProntuarioController();
  List<Paciente> _pacientes = [];

  @override
  void initState() {
    super.initState();
    _loadPacientes();
  }

  // Função para carregar os pacientes
  void _loadPacientes() async {
    List<Paciente> pacientes = await _prontuarioController.fetchPacientes();
    setState(() {
      _pacientes = pacientes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Registros de Prontuários - Pacientes"), // AppBar customizado
      body: _pacientes.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              itemCount: _pacientes.length,
              itemBuilder: (context, index) {
                final paciente = _pacientes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: const Color.fromARGB(150, 173, 216, 230), // Cor do cartão
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      paciente.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Clique para ver os prontuários',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // Ao selecionar um paciente, navega para a tela de prontuários
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProntuariosByPage(
                              pacienteId: paciente.id,
                            ),
                          ),
                        );
                      },
                    ),

                    
                  ),
                );
              },
            ),
               floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FormProntuarioPage()),
          );
        },
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Prontuário',
      )
    );
  }
}
