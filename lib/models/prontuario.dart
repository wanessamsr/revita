import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:revitalize_mobile/models/campo_adicional.dart';



class Prontuario {
  final String id;
  final String pacienteId;
  final String profissionalId;
  final String pacienteNome;
  final String profissionalNome;
  final String textoProntuario;
  final List<CampoAdicional> camposAdicionais;
  final String data;
  final DateTime createdAt; // Adicionando o campo createdAt

  Prontuario({
    required this.id,
    required this.pacienteId,
    required this.profissionalId,
    required this.pacienteNome,
    required this.profissionalNome,
    required this.textoProntuario,
    required this.camposAdicionais,
    required this.data,
    required this.createdAt, // Adicionando o campo no construtor
  });

  // Método para mapear os dados do prontuário para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pacienteId': pacienteId,
      'profissionalId': profissionalId,
      'pacienteNome': pacienteNome,
      'profissionalNome': profissionalNome,
      'textoProntuario': textoProntuario,
      'camposAdicionais': camposAdicionais.map((e) => e.toMap()).toList(),
      'data': data,
      'createdAt': createdAt.toIso8601String(), // Convertendo o createdAt para string ISO
    };
  }

  // Método para criar uma instância de Prontuario a partir de um ParseObject
  factory Prontuario.fromParse(ParseObject parseObject) {
    ParseObject paciente = parseObject.get<ParseObject>('paciente_id')!;
    String pacienteId = paciente.objectId ?? '';
    String pacienteNome = paciente.get<String>('nome') ?? 'Nome não disponível';

    ParseObject profissional = parseObject.get<ParseObject>('funcionario_id')!;
    String profissionalId = profissional.objectId ?? '';
    String profissionalNome = profissional.get<String>('nome') ?? 'Nome não disponível';
    
    String textoProntuario = parseObject.get<String>('conteudo') ?? '';
    String data = parseObject.get<String>('data') ?? '';
    
    // Obtendo o createdAt do ParseObject
    DateTime createdAt = parseObject.createdAt ?? DateTime.now(); // Se não houver createdAt, usa a data atual

    List<CampoAdicional> camposAdicionais = []; // Adapte conforme necessário

    return Prontuario(
      id: parseObject.objectId!,
      pacienteId: pacienteId,
      profissionalId: profissionalId,
      pacienteNome: pacienteNome,
      profissionalNome: profissionalNome,
      textoProntuario: textoProntuario,
      camposAdicionais: camposAdicionais,
      data: data,
      createdAt: createdAt, // Incluindo createdAt
    );
  }
}
