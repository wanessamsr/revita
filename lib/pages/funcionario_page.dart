import 'package:flutter/material.dart';
import 'package:revitalize_mobile/forms/form_edit_funcionario.dart';
import 'package:revitalize_mobile/forms/form_funcionario.dart';
import 'package:revitalize_mobile/testes/home_page.dart';
import 'package:revitalize_mobile/widgets/custom_table.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';
import 'package:revitalize_mobile/controllers/funcionario.dart';
import 'package:revitalize_mobile/models/funcionario.dart';
import 'package:revitalize_mobile/widgets/custom_text.dart';

class FuncionarioPageState extends StatefulWidget {
  const FuncionarioPageState({super.key});

  @override
  _FuncionarioPageState createState() => _FuncionarioPageState();
}

class _FuncionarioPageState extends State<FuncionarioPageState> {
  final FuncionarioController _controller = FuncionarioController();
  List<Funcionario> _funcionarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFuncionarios();
  }

  Future<void> _loadFuncionarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final funcionarios = await _controller.fetchFuncionarios();
      setState(() {
        _funcionarios = funcionarios;
      });
    } catch (e) {
      print("Erro ao buscar funcionários: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteFuncionario(int index) async {
    try {
      final funcionarioId = _funcionarios[index].id;

      await _controller.deleteFuncionario(funcionarioId);

      setState(() {
        _funcionarios.removeAt(index);
      });
    } catch (e) {
      print("Erro ao excluir funcionário: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir funcionário: $e")),
      );
    }
  }

  void _editFuncionario(Funcionario funcionario) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormEditFuncionarioPage(funcionario: funcionario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> nomeCampo = ['Id', 'Nome', 'Ocupação', 'Gênero'];

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Funcionários"),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth >= 600) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Center(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FormFuncionarioPage()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        tooltip: 'Adicionar',
                      ),
                    ),
                    SizedBox(
                        height: 8),
                    ..._funcionarios.map((funcionario) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomTextWidget(
                            titulo: nomeCampo,
                            dados: [
                              funcionario.id,
                              funcionario.nome,
                              funcionario.ocupacao,
                              funcionario.genero,
                              funcionario.email,
                            ],
                            onDelete: () {
                              _deleteFuncionario(
                                  _funcionarios.indexOf(funcionario));
                            },
                            onEdit: () {
                              _editFuncionario(funcionario);
                            },
                          ),
                        )),

                    SizedBox(height: 8),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Center(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FormFuncionarioPage()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        tooltip: 'Adicionar',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._funcionarios.map((funcionario) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomTable(
                            quantidadeCampo: '4',
                            nomeCampo: nomeCampo,
                            dados: [
                              funcionario.id,
                              funcionario.nome,
                              funcionario.ocupacao,
                              funcionario.genero,
                            ],
                          ),
                        )),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
