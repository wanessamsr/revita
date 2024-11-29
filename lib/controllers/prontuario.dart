import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:revitalize_mobile/models/funcionario.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/models/campo_adicional.dart';
import 'package:revitalize_mobile/models/prontuario.dart';

class ProntuarioController {


 Future<List<Prontuario>> fetchProntuariosByPaciente(String pacienteId) async {
  List<Prontuario> prontuarios = [];

  ParseObject pacientePointer = ParseObject('paciente')..objectId = pacienteId;

  QueryBuilder<ParseObject> queryProntuario = QueryBuilder<ParseObject>(ParseObject('ficha'));

  queryProntuario.whereEqualTo('paciente_id', pacientePointer);

  queryProntuario.includeObject(['paciente_id', 'funcionario_id']);

  final ParseResponse apiResponse = await queryProntuario.query();

  if (apiResponse.success && apiResponse.results != null) {
    for (var item in apiResponse.results as List<ParseObject>) {
      String pacienteId = '';
      String pacienteNome = '';
      String profissionalId = '';
      String profissionalNome = '';

      // Obtendo o paciente associado
      ParseObject? paciente = item.get<ParseObject>('paciente_id');
      if (paciente != null) {
        pacienteId = paciente.objectId ?? '';
        pacienteNome = paciente.get<String>('nome') ?? 'Nome não disponível';
      }

      ParseObject? profissional = item.get<ParseObject>('funcionario_id');
      if (profissional != null) {
        profissionalId = profissional.objectId ?? '';
        profissionalNome = profissional.get<String>('nome') ?? 'Nome não disponível';
      }

      prontuarios.add(Prontuario(
        id: item.objectId!,
        pacienteId: pacienteId,
        profissionalId: profissionalId,
        pacienteNome: pacienteNome,
        profissionalNome: profissionalNome,
        textoProntuario: item.get<String>('conteudo') ?? '',
        camposAdicionais: [], 
        data: item.get<String>('data') ?? '',
        createdAt: item.createdAt ?? DateTime.now(), 
      ));
    }
  }

  return prontuarios;
}
  
  
  Future<void> _loadCamposAdicionais(Prontuario prontuario) async {
    QueryBuilder<ParseObject> queryCampoAdicional =
        QueryBuilder<ParseObject>(ParseObject('campo_adicional'));
    queryCampoAdicional.whereEqualTo(
        'id_ficha', ParseObject('ficha')..objectId = prontuario.id);

    final ParseResponse response = await queryCampoAdicional.query();

    if (response.success && response.results != null) {
      List<CampoAdicional> camposAdicionais =
          (response.results as List<ParseObject>).map((campo) {
        return CampoAdicional(
          idFicha: campo.get<ParseObject>('id_ficha')?.objectId ?? '',
          valor: campo.get<String>('conteudo') ?? '',
        );
      }).toList();

      prontuario.camposAdicionais.addAll(camposAdicionais);
    } else {
      print('Erro ao carregar campos adicionais: ${response.error?.message}');
    }
  }

  Future<List<CampoAdicional>> fetchCamposAdicionais(String prontuarioId) async {
  List<CampoAdicional> camposAdicionais = [];

  QueryBuilder<ParseObject> queryCampoAdicional = QueryBuilder<ParseObject>(ParseObject('campo_adicional'));


  queryCampoAdicional.whereEqualTo('id_ficha', ParseObject('ficha')..objectId = prontuarioId);

  final ParseResponse apiResponse = await queryCampoAdicional.query();

  if (apiResponse.success && apiResponse.results != null) {
    for (var item in apiResponse.results as List<ParseObject>) {
      camposAdicionais.add(CampoAdicional(
        idFicha: prontuarioId,
        valor: item.get<String>('conteudo') ?? 'Sem conteúdo',
      ));
    }
  }

  return camposAdicionais;
}


  Future<List<Prontuario>> fetchProntuarios() async {
    List<Prontuario> prontuarios = [];

    QueryBuilder<ParseObject> queryProntuario =
        QueryBuilder<ParseObject>(ParseObject('ficha'));

    queryProntuario.includeObject(['paciente_id', 'funcionario_id']);

    final ParseResponse apiResponse = await queryProntuario.query();

    if (apiResponse.success && apiResponse.results != null) {
      for (var item in apiResponse.results as List<ParseObject>) {
        String pacienteId = '';
        String pacienteNome = '';
        String profissionalId = '';
        String profissionalNome = '';

        ParseObject? paciente = item.get<ParseObject>('paciente_id');
        if (paciente != null) {
          pacienteId = paciente.objectId ?? '';
          pacienteNome = paciente.get<String>('nome') ?? 'Nome não disponível';
        }

        ParseObject? profissional = item.get<ParseObject>('funcionario_id');
        if (profissional != null) {
          profissionalId = profissional.objectId ?? '';
          profissionalNome =
              profissional.get<String>('nome') ?? 'Nome não disponível';
        }

        prontuarios.add(Prontuario(
          id: item.objectId!,
          pacienteId: pacienteId,
          profissionalId: profissionalId,
          pacienteNome: pacienteNome,
          profissionalNome: profissionalNome,
          textoProntuario: item.get<String>('conteudo') ?? '',
          camposAdicionais: [], 
          data: item.get<String>('data') ?? '',
          createdAt:
              item.createdAt ?? DateTime.now(), 
        ));
      }
    }

    return prontuarios;
  }

  Future<List<Paciente>> fetchPacientes() async {
    List<Paciente> pacienteItems = [];
    QueryBuilder<ParseObject> queryPaciente =
        QueryBuilder<ParseObject>(ParseObject('paciente'));
    final ParseResponse apiResponse = await queryPaciente.query();

    if (apiResponse.success && apiResponse.results != null) {
      pacienteItems = (apiResponse.results as List<ParseObject>)
          .map((item) => Paciente.fromParse(item))
          .toList();
    } else {
      print('Erro ao buscar pacientes: ${apiResponse.error?.message}');
    }

    print('Pacientes carregados: ${pacienteItems.map((p) => p.nome).toList()}');

    return pacienteItems;
  }

  // Fetch Funcionários
  Future<List<Funcionario>> fetchFuncionarios() async {
    List<Funcionario> funcionarioItems = [];
    QueryBuilder<ParseObject> queryFuncionario =
        QueryBuilder<ParseObject>(ParseObject('funcionario'));

    final ParseResponse apiResponse = await queryFuncionario.query();

    if (apiResponse.success && apiResponse.results != null) {
      funcionarioItems = (apiResponse.results as List<ParseObject>)
          .map((item) => Funcionario.fromParse(item))
          .toList();
    }

    print(
        'Funcionários carregados: ${funcionarioItems.map((f) => f.nome).toList()}');

    return funcionarioItems;
  }

  Future<void> cadastrarProntuario(Prontuario prontuario) async {
    final ParseObject prontuarioParse = ParseObject('ficha');
    prontuarioParse.set(
        'paciente_id', await _getPaciente(prontuario.pacienteId));
    prontuarioParse.set(
        'funcionario_id', await _getProfissional(prontuario.profissionalId));
    prontuarioParse.set('conteudo', prontuario.textoProntuario);

    // Salvar o prontuário (ficha)
    final ParseResponse prontuarioResponse = await prontuarioParse.save();

    if (prontuarioResponse.success) {
      final ficha = prontuarioResponse.result as ParseObject;

      // Salvar campos adicionais
      for (var campo in prontuario.camposAdicionais) {
        await _saveCampoAdicional(ficha, campo);
      }
    } else {
      print(
          'Erro ao salvar o prontuário: ${prontuarioResponse.error?.message}');
      throw Exception(
          'Erro ao salvar o prontuário: ${prontuarioResponse.error?.message}');
    }
  }

  Future<ParseObject> _getPaciente(String pacienteId) async {
    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('paciente'))
          ..whereEqualTo('objectId', pacienteId);

    final ParseResponse apiResponse = await query.query();

    if (apiResponse.success &&
        apiResponse.results != null &&
        apiResponse.results!.isNotEmpty) {
      return apiResponse.results!.first as ParseObject;
    } else {
      print(
          'Paciente não encontrado ou resposta inválida: ${apiResponse.error?.message}');
      throw Exception('Paciente não encontrado');
    }
  }

  // Buscar profissional pelo ID
  Future<ParseObject> _getProfissional(String profissionalId) async {
    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('funcionario'))
          ..whereEqualTo('objectId', profissionalId);

    final ParseResponse apiResponse = await query.query();

    if (apiResponse.success &&
        apiResponse.results != null &&
        apiResponse.results!.isNotEmpty) {
      return apiResponse.results!.first as ParseObject;
    } else {
      print(
          'Profissional não encontrado ou resposta inválida: ${apiResponse.error?.message}');
      throw Exception('Profissional não encontrado');
    }
  }

  Future<void> _saveCampoAdicional(
      ParseObject ficha, CampoAdicional campo) async {
    final ParseObject campoAdicionalParse = ParseObject('campo_adicional');

    campoAdicionalParse.set(
        'id_ficha', ficha); 
    campoAdicionalParse.set('conteudo', campo.valor);

    final ParseResponse response = await campoAdicionalParse.save();

    if (!response.success) {
      print('Erro ao salvar campo adicional: ${response.error?.message}');
      throw Exception(
          'Erro ao salvar campo adicional: ${response.error?.message}');
    }
  }

  Future<void> deleteProntuario(String prontuarioId) async {
    final ParseObject prontuarioParse = ParseObject('ficha')..objectId = prontuarioId;

    final ParseResponse response = await prontuarioParse.delete();

    if (response.success) {
      print("Prontuário excluído com sucesso.");
    } else {
      print("Erro ao excluir prontuário: ${response.error?.message}");
      throw Exception("Erro ao excluir prontuário: ${response.error?.message}");
    }
  }

Future<void> atualizarProntuario(Prontuario prontuario) async {
  final ParseObject prontuarioParse = ParseObject('ficha')..objectId = prontuario.id;
  prontuarioParse.set('paciente_id', await _getPaciente(prontuario.pacienteId));
  prontuarioParse.set('funcionario_id', await _getProfissional(prontuario.profissionalId));
  prontuarioParse.set('conteudo', prontuario.textoProntuario);

  final ParseResponse prontuarioResponse = await prontuarioParse.save();

  if (prontuarioResponse.success) {
    final ficha = prontuarioResponse.result as ParseObject;

    await _deleteCamposAdicionais(ficha);
    for (var campo in prontuario.camposAdicionais) {
      await _saveCampoAdicional(ficha, campo);
    }
  } else {
    print('Erro ao salvar o prontuário: ${prontuarioResponse.error?.message}');
    throw Exception('Erro ao salvar o prontuário: ${prontuarioResponse.error?.message}');
  }
}

Future<void> _deleteCamposAdicionais(ParseObject ficha) async {
  final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('campo_adicional'))
    ..whereEqualTo('id_ficha', ficha);

  final ParseResponse response = await query.query();

  if (response.success && response.results != null) {
    for (var campo in response.results as List<ParseObject>) {
      await campo.delete();
    }
  }
}



}
