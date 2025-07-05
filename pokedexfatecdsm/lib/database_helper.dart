import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/usuario.dart';
import 'models/pokemon.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;
  final String baseUrl = 'http://10.0.0.246:8000'; // <-- Atualize aqui se mudar IP

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    await deleteDatabase(path); // <--- Força recriação

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            senha TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE pokemons (
            id INTEGER PRIMARY KEY,
            nome TEXT,
            tipo TEXT,
            imagem TEXT
          )
        ''');

        await db.insert('usuarios', {
          'email': 'fatec@pokemon.com',
          'senha': 'pikachu',
        });

        await _carregarPokemonsDoServidor(db);
      },
    );
  }

  /// Carrega pokémons do servidor e insere no SQLite
  Future<void> _carregarPokemonsDoServidor(Database db) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_pokemon.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Pokémons recebidos do servidor: $data');

        for (var p in data) {
          final imagemPath = 'assets/images/${p['imagem']}';
          await db.insert('pokemons', {
            'id': int.parse(p['id']),
            'nome': p['nome'],
            'tipo': p['tipo'],
            'imagem': imagemPath,
          });
          print('Inserido no SQLite: ${p['nome']}');
        }
      } else {
        print('Erro ao buscar pokémons: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar pokémons do servidor: $e');
    }
  }

  /// Login local
  Future<Usuario?> getUser(String email, String senha) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (result.isNotEmpty) {
      return Usuario(
        id: result.first['id'] as int,
        email: email,
        senha: senha,
      );
    }
    return null;
  }

  /// Lista pokémons do SQLite com log de debug
  Future<List<Pokemon>> getPokemons() async {
    final db = await database;
    final result = await db.query('pokemons');
    print('Pokémons carregados do SQLite: $result');

    return result.map((e) => Pokemon(
      id: e['id'] as int,
      nome: e['nome'] as String,
      tipo: e['tipo'] as String,
      imagem: e['imagem'] as String,
    )).toList();
  }

  /// Envia dados do SQLite para o MySQL
  Future<void> syncToMySQL() async {
    final db = await database;

    final usuarios = await db.query('usuarios');
    for (var usuario in usuarios) {
      await http.post(
        Uri.parse('$baseUrl/sync_user.php'),
        body: {
          'id': usuario['id'].toString(),
          'email': usuario['email'].toString(),
          'senha': usuario['senha'].toString(),
        },
      );
    }

    final pokemons = await db.query('pokemons');
    for (var p in pokemons) {
      await http.post(
        Uri.parse('$baseUrl/sync_pokemon.php'),
        body: {
          'id': p['id'].toString(),
          'nome': p['nome'].toString(),
          'tipo': p['tipo'].toString(),
          'imagem': p['imagem'].toString().split('/').last,
        },
      );
    }
  }
}
