import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import '../models/user.dart';

class DBHelper {
  DBHelper._privateConstructor();

  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'cadastro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        preco REAL NOT NULL
      )
    ''');

    await db.insert('users', {
      'email': 'admin@cadastro.com',
      'password': '123456',
    });
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users');
    return rows.map((row) => User.fromMap(row)).toList();
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    final data = user.toMap();
    data.remove('id');
    return await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final rows = await db.query('products');
    return rows.map((row) => Product.fromMap(row)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final data = product.toMap();
    data.remove('id');
    return await db.insert(
      'products',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> ensureSampleProducts() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products'),
    );

    if (count == 0) {
      await insertProduct(Product(
        nome: 'Produto 1',
        descricao: 'Descrição completa do produto 1.',
        preco: 29.90,
      ));
      await insertProduct(Product(
        nome: 'Produto 2',
        descricao: 'Descrição completa do produto 2.',
        preco: 59.90,
      ));
      await insertProduct(Product(
        nome: 'Produto 3',
        descricao: 'Descrição completa do produto 3.',
        preco: 99.90,
      ));
    }
  }
}
