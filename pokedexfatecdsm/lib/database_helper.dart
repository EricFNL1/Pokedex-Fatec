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

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

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

        await db.insert('users', {'email': 'fatec@pokemon.com', 'senha': 'pikachu'});

        List<Map<String, dynamic>> pokemons = [
          {'id': 1, 'nome': 'Bulbasaur', 'tipo': 'Grass/Poison', 'imagem': 'assets/images/bulbasaur.png'},
          {'id': 2, 'nome': 'Ivysaur', 'tipo': 'Grass/Poison', 'imagem': 'assets/images/ivysaur.png'},
          {'id': 3, 'nome': 'Venusaur', 'tipo': 'Grass/Poison', 'imagem': 'assets/images/venusaur.png'},
          {'id': 4, 'nome': 'Charmander', 'tipo': 'Fire', 'imagem': 'assets/images/charmander.png'},
          {'id': 5, 'nome': 'Charmeleon', 'tipo': 'Fire', 'imagem': 'assets/images/charmeleon.png'},
          {'id': 6, 'nome': 'Charizard', 'tipo': 'Fire/Flying', 'imagem': 'assets/images/charizard.png'},
          {'id': 7, 'nome': 'Squirtle', 'tipo': 'Water', 'imagem': 'assets/images/squirtle.png'},
          {'id': 8, 'nome': 'Wartortle', 'tipo': 'Water', 'imagem': 'assets/images/wartortle.png'},
          {'id': 9, 'nome': 'Blastoise', 'tipo': 'Water', 'imagem': 'assets/images/blastoise.png'},
          {'id': 10, 'nome': 'Caterpie', 'tipo': 'Bug', 'imagem': 'assets/images/caterpie.png'},
        ];

        for (var p in pokemons) {
          await db.insert('pokemons', p);
        }
      },
    );
  }

  Future<Usuario?> getUser(String email, String senha) async {
    final db = await database;
    final result = await db.query(
      'users',
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

  Future<List<Pokemon>> getPokemons() async {
    final db = await database;
    final result = await db.query('pokemons');
    return result.map((e) => Pokemon(
      id: e['id'] as int,
      nome: e['nome'] as String,
      tipo: e['tipo'] as String,
      imagem: e['imagem'] as String,
    )).toList();
  }

  Future<void> syncToMySQL() async {
    final db = await database;

    final usuarios = await db.query('usuarios');
    for (var usuario in usuarios) {
      await http.post(
        Uri.parse('https://url-do-servidor.com/api/sync_user.php'),
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
        Uri.parse('https://url-do-servidor.com/api/sync_pokemon.php'),
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
