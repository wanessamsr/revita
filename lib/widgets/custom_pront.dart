import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/campo_adicional.dart';
import 'package:revitalize_mobile/models/prontuario.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';

class CustomPront extends StatelessWidget {
  final List<String> nomeCampo;
  final List<String> dados;

  CustomPront({
    super.key,
    required this.nomeCampo,
    required this.dados,
  });

  @override
  Widget build(BuildContext context) {
    double availableHeight = MediaQuery.of(context).size.height;
    double availableWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usando um card com bordas arredondadas e sombra para destaque
            Container(
              padding: const EdgeInsets.all(16),
              width: availableWidth * 1.0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 173, 216, 230),
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(150, 173, 216, 230),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exibindo os campos do prontuário
                  ...List.generate(
                    nomeCampo.length, // Número de campos
                    (index) {
                      return _buildField(nomeCampo[index], dados[index]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para criar o campo
  Widget _buildField(String campo, String dado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título do campo
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            campo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        // Dado do campo
        Text(
          dado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16), // Espaço entre os campos
        Divider(color: Colors.grey[300]), // Linha divisória
      ],
    );
  }
}

class ProntuarioDetalhadoPage extends StatefulWidget {
  final Prontuario prontuario;

  const ProntuarioDetalhadoPage({Key? key, required this.prontuario}) : super(key: key);

  @override
  _ProntuarioDetalhadoPageState createState() => _ProntuarioDetalhadoPageState();
}

class _ProntuarioDetalhadoPageState extends State<ProntuarioDetalhadoPage> {
  final ProntuarioController _controller = ProntuarioController();
  late Future<List<CampoAdicional>> _camposAdicionais;

  @override
  void initState() {
    super.initState();
    // Buscar campos adicionais com base no prontuário
    _camposAdicionais = _controller.fetchCamposAdicionais(widget.prontuario.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Detalhes do Prontuário"),
      body: FutureBuilder<List<CampoAdicional>>(
        future: _camposAdicionais,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum campo adicional encontrado.'));
          }

          List<CampoAdicional> camposAdicionais = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                CustomPront(
                  nomeCampo: [
                    'Id',
                    'Paciente',
                    'Profissional',
                    'Data',
                    'Conteúdo',
                  ],
                  dados: [
                    widget.prontuario.id,
                    widget.prontuario.pacienteNome,
                    widget.prontuario.profissionalNome,
                    widget.prontuario.data,
                    widget.prontuario.textoProntuario,
                  ],
                ),
                // Exibindo campos adicionais
                if (camposAdicionais.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campos Adicionais:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // Espaço entre título e os campos
                        // Criando uma estrutura semelhante aos campos do prontuário
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(150, 173, 216, 230),
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(150, 173, 216, 230),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...camposAdicionais.map((campo) {
                                return _buildField(campo.valor);
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget para criar os campos adicionais
  Widget _buildField(String dado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16), // Espaço entre os campos adicionais
        Divider(color: Colors.grey[300]), // Linha divisória
      ],
    );
  }
}
