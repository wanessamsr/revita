import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Funcionario {
  String  id;
  String  nome;
  String  ocupacao;
  String  genero;
  String  cpf;
  String  email;
  String  endereco;
  String  cidade;
  String  cep;
  String senha;
  String  dataNascimento;

  Funcionario({
    required this.id,
    required this.nome,
    required this.ocupacao,
    required this.genero,
    required this.cpf,
    required this.email,
    required this.endereco,
    required this.cidade,
    required this.cep,
    required this.senha,
    required this.dataNascimento,
  });

  factory Funcionario.fromParse(ParseObject object) {
    return Funcionario(
      id: object.objectId!,
      nome: object.get<String>('nome') ?? '',
      ocupacao: object.get<String>('ocupacao') ?? '',
      genero: object.get<String>('genero') ?? '',
      cpf: object.get<String>('cpf') ?? '',
      email: object.get<String>('email') ?? '',
      endereco: object.get<String>('endereco') ?? '',
      cidade: object.get<String>('cidade') ?? '',
      cep: object.get<String>('cep') ?? '',
      senha: object.get<String>('senha') ?? '',
      dataNascimento: object.get<String>('data_nascimento') ?? '',
    );
  }
}
