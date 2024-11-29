import 'package:flutter/material.dart';
import 'package:revitalize_mobile/models/funcionario.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/campo_adicional.dart';
import 'package:revitalize_mobile/models/prontuario.dart';

import 'package:revitalize_mobile/widgets/app_bar.dart';

class EditarProntuarioPage extends StatefulWidget {
  final Prontuario prontuario;

  const EditarProntuarioPage({Key? key, required this.prontuario}) : super(key: key);

  @override
  _EditarProntuarioPageState createState() => _EditarProntuarioPageState();
}

class _EditarProntuarioPageState extends State<EditarProntuarioPage> {
  String? pacienteId;
  String? profissional;
  String prontuarioTexto = '';
  List<TextEditingController> _controllers = [];
  late Prontuario _prontuario;

  final ProntuarioController _controller = ProntuarioController();
  final List<Paciente> pacientes = [];
  final List<Funcionario> profissionais = [];

  @override
  void initState() {
    super.initState();
    _prontuario = widget.prontuario;
    pacienteId = _prontuario.pacienteId;
    profissional = _prontuario.profissionalId;
    prontuarioTexto = _prontuario.textoProntuario;
    _loadData();
    _loadCamposAdicionais(); 
  }

  Future<void> _loadData() async {
    final fetchedPacientes = await _controller.fetchPacientes();
    final fetchedFuncionarios = await _controller.fetchFuncionarios();

    setState(() {
      pacientes.addAll(fetchedPacientes);
      profissionais.addAll(fetchedFuncionarios);
    });

    // Carregar campos adicionais
    await _loadCamposAdicionais();
  }

  Future<void> _loadCamposAdicionais() async {
    try {
      final campos = await _controller.fetchCamposAdicionais(_prontuario.id);
      setState(() {
        _controllers = campos.map((campo) {
          return TextEditingController(text: campo.valor);
        }).toList();
      });
    } catch (e) {
      print('Erro ao carregar campos adicionais: $e');
    }
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
      appBar: CustomAppBar(title: 'Editar prontuário'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.person, size: 60)),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Paciente',
                value: pacienteId,
                items: pacientes.map((p) => p.id).toList(),
                displayItems: pacientes.map((p) => p.nome).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    pacienteId = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),

              _buildDropdown(
                label: 'Profissional',
                value: profissional,
                items: profissionais.map((f) => f.id).toList(),
                displayItems: profissionais.map((f) => f.nome).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    profissional = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),

              TextField(
                controller: TextEditingController(text: prontuarioTexto),
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

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (pacienteId != null &&
                        profissional != null &&
                        prontuarioTexto.isNotEmpty) {
                      try {
                        var prontuario = Prontuario(
                          id: _prontuario.id,
                          pacienteId: pacienteId!,
                          profissionalId: profissional!,
                          textoProntuario: prontuarioTexto,
                          camposAdicionais: _controllers
                              .map((controller) {
                                return CampoAdicional(
                                  idFicha: pacienteId!, 
                                  valor: controller.text,
                                );
                              })
                              .toList(),
                          data: _prontuario.data,
                          pacienteNome: _prontuario.pacienteNome,
                          profissionalNome: _prontuario.profissionalNome,
                          createdAt: _prontuario.createdAt,
                        );

                        await _controller.atualizarProntuario(prontuario);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Prontuário atualizado com sucesso!')));
                        Navigator.pop(context); // Volta para a página anterior
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Erro ao atualizar prontuário: $e')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Preencha todos os campos obrigatórios')));
                    }
                  },
                  child: const Text('Atualizar'),
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
    required List<String> items,
    required List<String> displayItems,
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
                  items.indexOf(item)]), // Exibe o nome do item
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
