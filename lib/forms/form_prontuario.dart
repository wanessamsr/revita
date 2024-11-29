import 'package:flutter/material.dart';
import 'package:revitalize_mobile/models/funcionario.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/campo_adicional.dart'; // Certifique-se de importar CampoAdicional
import 'package:revitalize_mobile/models/prontuario.dart';

import 'package:revitalize_mobile/widgets/app_bar.dart';

class FormProntuarioPage extends StatefulWidget {
  const FormProntuarioPage({super.key});

  @override
  __FormProntuarioPageState createState() => __FormProntuarioPageState();
}

class __FormProntuarioPageState extends State<FormProntuarioPage> {
  String? pacienteId;
  String? profissional;
  String prontuarioTexto = '';

  final List<Paciente> pacientes = [];
  final List<Funcionario> profissionais = [];
  final ProntuarioController _controller = ProntuarioController();
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedPacientes = await _controller.fetchPacientes();
    final fetchedFuncionarios = await _controller.fetchFuncionarios();

    setState(() {
      pacientes.addAll(fetchedPacientes);
      profissionais.addAll(fetchedFuncionarios);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Cadastro Prontuário"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.person, size: 60)),
              const SizedBox(height: 20),

              // Dropdown de Pacientes
              _buildDropdown(
                label: 'Paciente',
                value: pacienteId,
                items: pacientes
                    .map((p) => p.id)
                    .toList(), // Mapeando os IDs dos pacientes
                displayItems:
                    pacientes.map((p) => p.nome).toList(), // Exibindo os nomes
                onChanged: (String? newValue) {
                  setState(() {
                    pacienteId = newValue;

                    final selectedPaciente = pacientes.firstWhere(
                      (p) => p.id == newValue,
                      orElse: () => Paciente(
                        id: '',
                        nome: '',
                        cpf: '',
                        email: '',
                        endereco: '',
                        cidade: '',
                        cep: '',
                        dataNascimento: '',
                      ),
                    );

                    pacienteId = selectedPaciente.id;
                    print('Paciente selecionado: $pacienteId');
                  });
                },
              ),
              const SizedBox(height: 10),

              // Dropdown de Profissionais
              _buildDropdown(
                label: 'Profissional',
                value: profissional,
                items: profissionais
                    .map((f) => f.id)
                    .toList(), // Mapeando os IDs dos profissionais
                displayItems: profissionais
                    .map((f) => f.nome)
                    .toList(), // Exibindo os nomes
                onChanged: (String? newValue) {
                  setState(() {
                    profissional = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Prontuário Text Field
              TextField(
                onChanged: (text) {
                  prontuarioTexto = text;
                },
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Prontuário',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Campos adicionais
              Column(
                children: _controllers.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextField(
                      controller: controller,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Informação Adicional',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Adicionar campo
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controllers.add(TextEditingController());
                    });
                  },
                  child: const Text('Adicionar Campo'),
                ),
              ),
              const SizedBox(height: 10),

              // Remover último campo
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_controllers.isNotEmpty) {
                      setState(() {
                        _controllers.removeLast();
                      });
                    }
                  },
                  child: const Text('Remover Último Campo'),
                ),
              ),
              const SizedBox(height: 20),

              // Botão de Cadastro
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (pacienteId != null &&
                        profissional != null &&
                        prontuarioTexto.isNotEmpty) {
                      try {
                        var prontuario = Prontuario(
                          pacienteId: pacienteId!,
                          profissionalId: profissional!,
                          textoProntuario: prontuarioTexto,
                          camposAdicionais: _controllers
                              .map((controller) {
                                return CampoAdicional(
                                  idFicha: pacienteId!,  // Aqui associamos o id da ficha
                                  valor: controller.text,
                                );
                              })
                              .toList(), id: '', data: '', pacienteNome: '', profissionalNome: '', createdAt: DateTime.now(), // Convertemos explicitamente para List<CampoAdicional>
                        );

                        await _controller.cadastrarProntuario(prontuario);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Prontuário cadastrado com sucesso!')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Erro ao cadastrar prontuário: $e')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Preencha todos os campos obrigatórios')));
                    }
                  },
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items, // Lista com os IDs
    required List<String> displayItems, // Lista com os nomes para exibir
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(displayItems[
                  items.indexOf(item)]), // Exibe o nome correspondente ao ID
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text('Selecione um $label'),
          underline: Container(
            height: 1,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
