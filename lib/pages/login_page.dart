import 'package:flutter/material.dart';
import 'package:revitalize_mobile/pages/reset_page.dart';
import 'package:revitalize_mobile/pages/tela_inicial.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  __LoginPageState createState() => __LoginPageState();
}

class __LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  bool isLoggedIn = false;
  double _buttonScale = 1.0; // Escala inicial do botão
  Color _buttonColor = Colors.white; // Cor inicial do botão

  @override
  void initState() {
    super.initState();
  }

  void showSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showError(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void login(String email, String password) async {
    final user = ParseUser(email, password, null);
    var response = await user.login();

    if (response.success) {
      showSuccess("User was successfully login!");
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );

      setState(() {
        isLoggedIn = true;
      });
    } else {
      showError(response.error!.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF006699)], // Gradiente azul
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo maior
                Image.asset(
                  'assets/images/logo.png',
                  width: 900,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 0),
                // Campo de Email
                TextField(
                  onChanged: (text) {
                    email = text;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 10),
                // Campo de Senha
                TextField(
                  obscureText: true,
                  onChanged: (text) {
                    password = text;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // Botão de Entrar com animação de escala e mudança de cor ao clicar
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _buttonScale =
                          1.05; // Aumenta levemente ao passar o mouse
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _buttonScale = 1.0; // Retorna ao tamanho original ao sair
                      _buttonColor = Colors.white; // Retorna à cor original
                    });
                  },
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _buttonScale = 0.95; // Escala reduzida ao clicar
                        _buttonColor =
                            const Color(0xFF006699); // Muda para azul ao clicar
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _buttonScale =
                            1.0; // Retorna à escala normal após o clique
                        _buttonColor = Colors.white; // Retorna à cor original
                      });
                      login(email, password);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      transform: Matrix4.identity()..scale(_buttonScale),
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _buttonColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            color: _buttonColor == Colors.white
                                ? const Color(0xFF003366)
                                : Colors
                                    .white, // Muda a cor do texto conforme o fundo
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Esqueceu sua senha?
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const  ResetPasswordPage()),
      );

                   
                  },
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
