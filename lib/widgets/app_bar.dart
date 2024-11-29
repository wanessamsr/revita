import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack, // Função de callback para recarregar dados
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (onBack != null) {
            onBack!(); // Chama a função de recarregar dados
          }
          Navigator.of(context).pop(); // Voltar para a tela anterior
        },
      ),
      backgroundColor: const Color.fromARGB(255, 28, 5, 82),
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight);
  }
}
