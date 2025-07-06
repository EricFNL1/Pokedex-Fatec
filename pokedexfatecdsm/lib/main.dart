import 'package:flutter/material.dart';
import 'tela_login.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Fatec - Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaLogin(),
    );
  }
}
