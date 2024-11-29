import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final List<String> titulo;
  final List<String> dados;
  final VoidCallback onDelete;  // Callback para deletar
  final VoidCallback onEdit;    // Callback para editar

  // Construtor com os parâmetros necessários
  CustomTextWidget({
    required this.titulo,
    required this.dados,
    required this.onDelete,  // Define o parâmetro onDelete
    required this.onEdit,    // Define o parâmetro onEdit
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,  // Controlando a largura para permitir vários widgets lado a lado
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 173, 216, 230),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color.fromARGB(150, 173, 216, 230),
          width: 2.0,  // Largura da borda
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibindo cada item de dados
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(titulo.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RichText(
                          text: TextSpan(
                            text: '${titulo[index]}: ',
                            style: TextStyle(
                              fontSize: 14.0,  // Tamanho de fonte menor para compactação
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text: dados[index],
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Colocando os botões de editar e excluir
                Column(
                  children: [
                    IconButton(
                      onPressed: onEdit,  // Ao clicar, executa o método onEdit
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      iconSize: 20.0,  // Tamanho menor do ícone
                    ),
                    IconButton(
                      onPressed: onDelete,  // Ao clicar, executa o método onDelete
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Excluir',
                      color: Colors.red,
                      iconSize: 20.0,  // Tamanho menor do ícone
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
