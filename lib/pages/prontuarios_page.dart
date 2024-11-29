import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/prontuario.dart';
import 'package:revitalize_mobile/forms/form_prontuario.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';

class ProntuariosPage extends StatefulWidget {
  const ProntuariosPage({Key? key}) : super(key: key);

  @override
  _ProntuariosPageState createState() => _ProntuariosPageState();
}

class _ProntuariosPageState extends State<ProntuariosPage> {
  final ProntuarioController _controller = ProntuarioController();
  late Future<List<Prontuario>> _prontuarios;

  @override
  void initState() {
    super.initState();
    _prontuarios = _controller.fetchProntuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Prontuários"),
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
                      Text('Data de Criação: $createdAtString'), // Exibindo a data sem formatação
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.pageview_outlined),
                    onPressed: () {
                      // Navegar para a tela de detalhes do prontuário
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FormProntuarioPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Prontuário',
      ),
    );
  }
}
