import 'package:flutter/material.dart';
import 'package:revitalize_mobile/controllers/prontuario.dart';
import 'package:revitalize_mobile/models/campo_adicional.dart';
import 'package:revitalize_mobile/models/prontuario.dart';
import 'package:revitalize_mobile/widgets/app_bar.dart';
import 'package:revitalize_mobile/widgets/custom_pront.dart';

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
    // Fetch additional fields based on the prontuário
    _camposAdicionais = _controller.fetchCamposAdicionais(widget.prontuario.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Detalhes do Prontuário"),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: FutureBuilder<List<CampoAdicional>>(
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
                  // CustomPront is used to display the primary prontuário details
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
                      widget.prontuario.createdAt.toString(),
                      widget.prontuario.textoProntuario,
                    ],
                  ),
                  // Campos adicionais section with improved layout
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campos Adicionais:',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Improved layout for campos adicionais with cards
                        ...camposAdicionais.map((campo) {
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.label,
                                    color: Colors.blueAccent,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      campo.valor,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
