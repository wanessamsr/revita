import 'package:flutter/material.dart';
import 'package:revitalize_mobile/pages/login_page.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// Widget -> componentres (classes) (tela) -> recebe filhos
// StatelessWidget -> Nada se altera (estado)
// Container -> global, Text -> local
// Statefull permite alterar a visualização durante o app
// setState() -> modifica o estado, fruto do statefull
// Material App -> estilização
// Container() - > Parecido com a div
// Multi render (design sobre outros renders) e single render ->
// ChangeNotifier - > apenas regra de negócio!!

void main() async {
  runApp(const AppWideget());

  const keyApplicationId = '9EFKCAxEBXXDQ8XY6Itu5opkksqQQLecwgngOZl7';
  const keyClientKey = 'u1oZ9MXK0choNhZIwjonc6MzTIiSXcvTQiCZgter';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  /*void doUserRegistration() async {
    final username = "admin@gmail.com";
    final email = "admin@gmail.com";
    final password = "123456789A!";

  //email, password, email
    final user = ParseUser.createUser(username, password, null);

    var response = await user.signUp();

    if (response.success) {
      print("Sucesso");
    } else {
      print("response.error!.message");
    }
  }*/

  //doUserRegistration();
}

// StatelessWidget -> É estático!

class AppWideget extends StatelessWidget {
  const AppWideget({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      //routes:  ,
    );
  }
}
