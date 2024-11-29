import 'package:flutter/material.dart';
import 'package:revitalize_mobile/forms/form_edit_paciente.dart';
import 'package:revitalize_mobile/forms/form_paciente.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';
import 'package:revitalize_mobile/widgets/custom_table.dart';
import 'package:revitalize_mobile/controllers/paciente.dart'; 
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/widgets/custom_text.dart'; 

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
    // Aqui o método de fetch será chamado de maneira assíncrona
    return await _pacienteController.getPacientes();
  }

  void _deletePaciente(String id, int index) async {
    await _pacienteController.deletePaciente(id);
    setState(() {
      _pacientesFuture = _fetchPacientes(); 
    });
  }

  void _addPaciente() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FormPacientePage(),
      ),
    ).then((newPaciente) {
      if (newPaciente != null) {
        setState(() {
          _pacientesFuture = _fetchPacientes(); 
        });
      }
    });
  }

  void _editPaciente(Paciente paciente) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditarPacientePage(paciente: paciente),
      ),
    ).then((updatedPaciente) {
      if (updatedPaciente != null) {
        setState(() {
          _pacientesFuture = _fetchPacientes(); 
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pacientesFuture = _fetchPacientes(); 
  }

  @override
  Widget build(BuildContext context) {
    List<String> nomeCampo = [
      'Id',
      'Paciente',
      'Data Nascimento',
      'E-mail',
      'Endereço',
      'Cidade',
      'CEP',
    ];

    return Scaffold(
      appBar: CustomAppBar(title: "Pacientes"),
      body: FutureBuilder<List<Paciente>>(
        future: _pacientesFuture, // Passa o futuro de pacientes aqui
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Exibe indicador de carregamento enquanto espera
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Exibe erro caso a requisição falhe
            return Center(child: Text('Erro ao carregar pacientes: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Caso não tenha dados ou a lista esteja vazia
            return Center(child: Text('Nenhum paciente encontrado.'));
          } else {
            // Se os dados forem carregados corretamente, exibe a lista
            List<Paciente> pacientes = snapshot.data!;
            return SingleChildScrollView(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth >= 600) {
                    return Column(
                      children: [
                        IconButton(
                          onPressed: _addPaciente,
                          icon: const Icon(Icons.add),
                          tooltip: 'Adicionar',
                        ),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(pacientes.length, (index) {
                            return CustomTextWidget(
                              titulo: nomeCampo,
                              dados: [
                                pacientes[index].id,
                                pacientes[index].nome,
                                pacientes[index].dataNascimento,
                                pacientes[index].email,
                                pacientes[index].endereco,
                                pacientes[index].cidade,
                                pacientes[index].cep,
                              ],
                              onDelete: () => _deletePaciente(pacientes[index].id, index),
                              onEdit: () => _editPaciente(pacientes[index]), 
                            );
                          }),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        IconButton(
                          onPressed: _addPaciente,
                          icon: const Icon(Icons.add),
                          tooltip: 'Adicionar',
                        ),
                        SizedBox(height: 8),
                        ...List.generate(pacientes.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CustomTable(
                              quantidadeCampo: '8',
                              nomeCampo: nomeCampo,
                              dados: [
                                pacientes[index].id,
                                pacientes[index].nome,
                                pacientes[index].dataNascimento,
                                pacientes[index].email,
                                pacientes[index].endereco,
                                pacientes[index].cidade,
                                pacientes[index].cep,
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}


class CustomTextWidget extends StatelessWidget {
  final List<String> titulo;
  final List<String> dados;
  final VoidCallback onDelete;  
  final VoidCallback onEdit;    

  CustomTextWidget({
    required this.titulo,
    required this.dados,
    required this.onDelete,  
    required this.onEdit,    
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 173, 216, 230),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color.fromARGB(150, 173, 216, 230),
          width: 2.0,  
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(titulo.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RichText(
                          text: TextSpan(
                            text: '${titulo[index]}: ',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text: dados[index],
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: onEdit,  
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      iconSize: 20.0,
                    ),
                    IconButton(
                      onPressed: onDelete,  
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Excluir',
                      color: Colors.red,
                      iconSize: 20.0,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
