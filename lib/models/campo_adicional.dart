import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CampoAdicional {
  final String idFicha;
  final String valor;

  CampoAdicional({
    required this.idFicha,
    required this.valor,
  });

  // Método para mapear para um mapa
  Map<String, dynamic> toMap() {
    return {
      'id_ficha': idFicha,
      'conteudo': valor,
    };
  }

  // Construtor de fábrica para criar um CampoAdicional a partir de um ParseObject
  factory CampoAdicional.fromParse(ParseObject parseObject) {
    return CampoAdicional(
      idFicha: parseObject.objectId ?? '',
      valor: parseObject.get<String>('conteudo') ?? '',
    );
  }
}
