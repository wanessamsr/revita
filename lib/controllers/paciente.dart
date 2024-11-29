import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:revitalize_mobile/models/paciente.dart';
import 'package:revitalize_mobile/models/cidade.dart';

class PacienteController {
  Future<List<Cidade>> fetchCidades() async {
    List<Cidade> cidadeItems = [];
    QueryBuilder<ParseObject> queryCidade = QueryBuilder<ParseObject>(ParseObject('cidade'));

    final ParseResponse apiResponse = await queryCidade.query();

    if (apiResponse.success && apiResponse.results != null) {
      cidadeItems = (apiResponse.results as List<ParseObject>)
          .map((item) => Cidade(
                id: item.objectId!,
                nome: item.get<String>('cidade_nome') ?? '',
              ))
          .where((cidade) => cidade.nome.isNotEmpty)
          .toList();
    }

    return cidadeItems;
  }

  Future<void> savePaciente(Paciente paciente) async {
    final pacienteObject = ParseObject('paciente')
      ..set('nome', paciente.nome)
      ..set('cpf', paciente.cpf)
      ..set('email', paciente.email)
      ..set('endereco', paciente.endereco)
      ..set('cidade_id', ParseObject('cidade')..objectId = paciente.cidade)
      ..set('cep', paciente.cep)
      ..set('data_nascimento', paciente.dataNascimento);

    if (paciente.id.isNotEmpty) {
      pacienteObject.objectId = paciente.id;
    }

    final response = await pacienteObject.save();

    if (response.success) {
      print('Paciente salvo ou atualizado com sucesso!');
    } else {
      print('Erro ao salvar ou atualizar paciente: ${response.error?.message}');
    }
  }

  Future<List<Paciente>> getPacientes() async {
    List<Paciente> pacientes = [];
    QueryBuilder<ParseObject> queryPaciente = QueryBuilder<ParseObject>(ParseObject('paciente'));

    final ParseResponse apiResponse = await queryPaciente.query();

    if (apiResponse.success && apiResponse.results != null) {
      for (var item in apiResponse.results as List<ParseObject>) {
        String cidadeId = item.get<ParseObject>('cidade_id')?.objectId ?? '';

        String cidadeNome = '';
        if (cidadeId.isNotEmpty) {
          QueryBuilder<ParseObject> queryCidade = QueryBuilder<ParseObject>(ParseObject('cidade'))
            ..whereEqualTo('objectId', cidadeId);
          final cidadeResponse = await queryCidade.query();

          if (cidadeResponse.success && cidadeResponse.results != null && cidadeResponse.results!.isNotEmpty) {
            cidadeNome = (cidadeResponse.results!.first as ParseObject).get<String>('cidade_nome') ?? '';
          }
        }

        pacientes.add(Paciente(
          id: item.objectId!,
          nome: item.get<String>('nome') ?? '',
          cpf: item.get<String>('cpf') ?? '',
          email: item.get<String>('email') ?? '',
          endereco: item.get<String>('endereco') ?? '',
          cidade: cidadeNome, 
          cep: item.get<String>('cep') ?? '',
          dataNascimento: item.get<String>('data_nascimento') ?? '',
        ));
      }
    }

    return pacientes;
  }

  Future<void> deletePaciente(String id) async {
    final paciente = ParseObject('paciente')..objectId = id;
    final response = await paciente.delete();

    if (response.success) {
      print('Paciente deletado com sucesso!');
    } else {
      print('Erro ao deletar paciente: ${response.error?.message}');
    }
  }
}
