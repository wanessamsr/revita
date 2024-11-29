import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:revitalize_mobile/models/funcionario.dart';
import 'package:revitalize_mobile/models/ocupacao.dart';
import 'package:revitalize_mobile/models/cidade.dart';

class FuncionarioController {
  Future<List<Ocupacao>> fetchOcupacoes() async {
    List<Ocupacao> ocupacaoItems = [];
    QueryBuilder<ParseObject> queryOcupacao =
        QueryBuilder<ParseObject>(ParseObject('ocupacao'));

    final ParseResponse apiResponse = await queryOcupacao.query();

    if (apiResponse.success && apiResponse.results != null) {
      ocupacaoItems = (apiResponse.results as List<ParseObject>)
          .map((item) => Ocupacao(
                id: item.objectId!,
                nome: item.get<String>('nome_ocupacao') ?? '',
              ))
          .where((ocupacao) => ocupacao.nome.isNotEmpty)
          .toList();
    }

    return ocupacaoItems;
  }

  Future<List<Cidade>> fetchCidades() async {
    List<Cidade> cidadeItems = [];
    QueryBuilder<ParseObject> queryCidade =
        QueryBuilder<ParseObject>(ParseObject('cidade'));

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

  Future<void> saveFuncionario(Funcionario funcionario) async {

    Future<String?> doUserRegistration(String email, String senha) async {
      final user = ParseUser.createUser(email, senha, email);
      final response = await user.signUp();

      if (response.success) {
        return user.objectId;
      } else {
        print("Erro no registro do usuário: ${response.error?.message}");
        return null;
      }
    }

    final lastId = await doUserRegistration(funcionario.email, funcionario.senha);
    if (lastId == null) {
      print("Erro: não foi possível obter o objectId do usuário.");
      return;
    }

    final funcionarioObject = ParseObject('funcionario')
      ..set('nome', funcionario.nome)
      ..set('ocupacao_id', ParseObject('ocupacao')..objectId = funcionario.ocupacao) 
      ..set('genero', funcionario.genero)
      ..set('cpf', funcionario.cpf)
      ..set('email', funcionario.email)
      ..set('endereco', funcionario.endereco)
      ..set('cidade_id', ParseObject('cidade')..objectId = funcionario.cidade) 
      ..set('cep', funcionario.cep)
      ..set('data_nascimento', funcionario.dataNascimento)
      ..set('usuario_id', ParseObject('_User')..objectId = lastId); 

  //print('Ocupacao ID: ${funcionario.ocupacao}');

    final response = await funcionarioObject.save();

    if (!response.success) {
      print('Erro ao salvar funcionário: ${response.error?.message}');
    } else {
      print('Funcionário salvo com sucesso!');
    }
  }

  Future<List<Funcionario>> fetchFuncionarios() async {
    List<Funcionario> funcionarioItems = [];
    QueryBuilder<ParseObject> queryFuncionario =
        QueryBuilder<ParseObject>(ParseObject('funcionario'))
          ..includeObject(['ocupacao_id', 'cidade_id', 'usuario_id']);

    final ParseResponse apiResponse = await queryFuncionario.query();

    if (apiResponse.success && apiResponse.results != null) {
      funcionarioItems = (apiResponse.results as List<ParseObject>)
          .map((item) => Funcionario(
                id: item.objectId!,
                nome: item.get<String>('nome') ?? '',
                ocupacao: item.get<ParseObject>('ocupacao_id')?.get<String>('nome_ocupacao') ?? '',
                cidade: item.get<ParseObject>('cidade_id')?.get<String>('cidade_nome') ?? '',
                genero: item.get<String>('genero') ?? '',
                email: item.get<String>('email') ?? '', 
                senha: item.get<String>('senha')  ?? '', 
                cpf: item.get<String>('cpf') ?? '', 
                endereco: item.get<String>('endereco') ?? '', 
                cep: item.get<String>('cep') ?? '', 
                dataNascimento: item.get<String>('data_nascimento') ?? '',
              ))
          .toList();
    }

    return funcionarioItems;
  }

  Future<void> deleteFuncionario(String id) async {
  try {
    // Busca o objeto Funcionario pelo ID
    final funcionarioObject = ParseObject('funcionario')..objectId = id;

    // Deleta o objeto
    final response = await funcionarioObject.delete();

    if (response.success) {
      print("Funcionário com ID $id excluído com sucesso.");
    } else {
      print("Erro ao excluir funcionário: ${response.error?.message}");
    }
  } catch (e) {
    print("Erro ao excluir funcionário: $e");
    throw Exception("Erro ao excluir funcionário: $e");
  }
}
Future<void> updateFuncionario(Funcionario funcionario) async {
  try {
    final funcionarioObject = ParseObject('funcionario')..objectId = funcionario.id;

    funcionarioObject
      ..set('nome', funcionario.nome)
      ..set('ocupacao_id', ParseObject('ocupacao')..objectId = funcionario.ocupacao)
      ..set('genero', funcionario.genero)
      ..set('cpf', funcionario.cpf)
      ..set('email', funcionario.email)
      ..set('endereco', funcionario.endereco)
      ..set('cidade_id', ParseObject('cidade')..objectId = funcionario.cidade)
      ..set('cep', funcionario.cep)
      ..set('senha', funcionario.senha)
      ..set('data_nascimento', funcionario.dataNascimento);

    final response = await funcionarioObject.save();
    if (response.success) {
      print('Funcionario atualizado com sucesso!');
    } else {
      print('Erro ao atualizar funcionário');
    }
  } catch (e) {
    print('Erro ao atualizar: $e');
  }
}


}


