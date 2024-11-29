import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/prontuario.dart';
import 'package:revitalize_mobile/forms/form_edit_prontuario.dart';
import 'package:revitalize_mobile/pages/prontuario_detalhado.dart'; // Página de detalhes
//import 'package:revitalize_mobile/pages/editar_prontuario.dart'; // Nova página para edição
import 'package:revitalize_mobile/testes/home_page.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';

class ProntuariosByPage extends StatefulWidget {
  final String pacienteId;

  const ProntuariosByPage({Key? key, required this.pacienteId}) : super(key: key);

  @override
  _ProntuariosByPageState createState() => _ProntuariosByPageState();
}

class _ProntuariosByPageState extends State<ProntuariosByPage> {
  final ProntuarioController _controller = ProntuarioController();
  late Future<List<Prontuario>> _prontuarios;

  @override
  void initState() {
    super.initState();
    _prontuarios = _controller.fetchProntuariosByPaciente(widget.pacienteId);
  }

  // Função para deletar prontuário
  void _deleteProntuario(String prontuarioId) async {
    try {
      await _controller.deleteProntuario(prontuarioId);
      setState(() {
        _prontuarios = _controller.fetchProntuariosByPaciente(widget.pacienteId); // Recarrega a lista de prontuários
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Prontuário excluído com sucesso'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao excluir prontuário: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Prontuários do Paciente"),
      body: FutureBuilder<List<Prontuario>>(
        future: _prontuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum prontuário encontrado.'));
          }

          List<Prontuario> prontuarios = snapshot.data!;

          return ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              Prontuario prontuario = prontuarios[index];

              // Exibindo a data sem formatação
              String createdAtString = prontuario.createdAt.toString();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                color: const Color.fromARGB(150, 173, 216, 230),
                child: ListTile(
                  title: Text('Paciente: ${prontuario.pacienteNome}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profissional: ${prontuario.profissionalNome}'),
                      Text('Data de Criação: $createdAtString'),
                      Text('Conteúdo: ${prontuario.textoProntuario}'),
                      // Exibindo campos adicionais
                      ...prontuario.camposAdicionais.map((campo) {
                        return Text('Campo Adicional: ${campo.valor}');
                      }).toList(),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de Visualizar
                      IconButton(
                        icon: const Icon(Icons.pageview_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProntuarioDetalhadoPage(
                                prontuario: prontuario, // Passa o prontuário para a página de detalhes
                              ),
                            ),
                          );
                        },
                      ),
                      // Botão de Editar
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarProntuarioPage(
                              prontuario: prontuario, // Passa o prontuário para a página de edição
                              ),
                            ),
                          );
                        },
                      ),
                      // Botão de Excluir
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Confirmar exclusão
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Excluir Prontuário'),
                                content: const Text('Você tem certeza que deseja excluir este prontuário?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteProntuario(prontuario.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
