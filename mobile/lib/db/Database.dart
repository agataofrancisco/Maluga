import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MalugaDatabase {
  static final MalugaDatabase instance = MalugaDatabase._init();
  static Database? _database;
  MalugaDatabase._init();

  Future <Database?> get database async{
    if (_database != null) return _database!;
    _database = await _initDB('maluga.db');
    return _database;
  }

  //INICIALIZAÇÃO DO BANCO DE DADOS
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 3, onCreate: _createDB);
  }
  //CRIAÇÃO DAS TABELAS DO BANCO
  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS profile (
      id_profile INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      nif TEXT NOT NULL,
      location TEXT NOT NULL,
      id_number TEXT NOT NULL UNIQUE,
      classification REAL NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS alugador (
      id_alugador INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      nif TEXT NOT NULL,
      location TEXT NOT NULL,
      phone_number TEXT NOT NULL, 
      classification REAL NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS kilapeiro (
      id_kilapeiro INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      nif TEXT NOT NULL,
      location TEXT NOT NULL,
      phone_number TEXT NOT NULL, 
      classification REAL
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS notifications (
      id_notification INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL CHECK(type IN ('alugo', 'kilapi')),
      message TEXT NOT NULL,
      date_sent TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS materials (
      id_material INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      status TEXT NOT NULL CHECK(status IN ('novo', 'semi-novo', 'antigo')),
      price REAL NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS historico (
      id_historico INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      data DATE NOT NULL,
      materials TEXT NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('alugo', 'kilapi')),
      total REAL NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE alugos (
  id_alugo INTEGER PRIMARY KEY AUTOINCREMENT,
  name_alugador TEXT NOT NULL,
  nif_alugador TEXT NOT NULL,
  contact_alugador TEXT NOT NULL,
  date_alugo DATE NOT NULL,
  date_return DATE NOT NULL,
  total_alugo REAL NOT NULL,
  contract_image TEXT
);

CREATE TABLE alugo_items (
  id_item INTEGER PRIMARY KEY AUTOINCREMENT,
  id_alugo INTEGER NOT NULL,         -- Este campo liga cada item ao seu aluguel
  material TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (id_alugo) REFERENCES alugos(id_alugo) ON DELETE CASCADE
);
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS kilapis (
      id_kilapi INTEGER PRIMARY KEY AUTOINCREMENT,
      name_kilapeiro TEXT NOT NULL,
      nif_kilapeiro TEXT NOT NULL,
      contact_kilapeiro TEXT NOT NULL,
      materials TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      date_kilapi TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
      date_return DATE NOT NULL,
      total_kilapi REAL NOT NULL,
      contract_image TEXT
    );
  ''');
}
  //FUNCTION TO INSERT DATA TO AN SPECIFIC TABLE
  Future <int> insert(String table, Map<String, dynamic> data) async{
    final db = await instance.database;
    debugPrint("INFORMAÇÕES ADICIONADAS");
    return await db!.insert(table, data);
  }

  //CLEAR A TABLE
  Future<void> clearTable(String table) async{
    final db= await instance.database;
    await db!.delete(table);
    debugPrint("TABELA $table Limpa com sucesso");
  }

  // Update data in a specific table
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    return await db!.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<void>deleteTable(String table) async{
    final db = await instance.database;
    await db!.execute('DROP TABLE IF EXISTS $table');
    debugPrint("Tabela $table deletada com sucesso.");
  }
  //GET ALL DATA FROM THE TABLE 
  Future<List<Map<String, dynamic>>> getAllMaterials(String table)  async {
    final db = await instance.database;
    return await db!.query(
      table,
      where: 'quantity > ?', // Filtra produtos com quantidade > 0
      whereArgs: [0],
      orderBy: 'name ASC', // Ordena por nome em ordem alfabética
    );
  }
  //FUNÇÃO PARA OBTER TODOS OS DADOS DA TABELA ORDENADOS DE FORMA CRESCENTE
  Future<List<Map<String, dynamic>>> getAllData(String table,String ordem) async {
    final db = await instance.database; 
    return await db!.query(table,orderBy: '$ordem DESC');
  }
  //PRINT ALL DATA IN TABLE
  /*Future<void> printTableData(String table) async {
    final data = await getAllData(table,'id_material');
    if (data.isEmpty) {
      print('A tabela $table está vazia.');
    } else {
      print('Dados da tabela $table:');
      for (var item in data) {
        print(item);
      }
    }
  }*/
  // Obter dados de uma tabela específica com base no ID~

  //CRIAR UMA TABELA ESPECIFICA
  Future<void> createTable() async {
    final db = await instance.database;
    await db!.execute('''
    CREATE TABLE alugo_items (
      id_item INTEGER PRIMARY KEY AUTOINCREMENT,
      id_alugo INTEGER NOT NULL,         -- Este campo liga cada item ao seu aluguel
      material TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY (id_alugo) REFERENCES alugos(id_alugo) ON DELETE CASCADE
    );''');
    debugPrint("Tabela criada com sucesso.");
  }
  Future<Map<String, dynamic>?> getData(String table, int id, {String idColumn = 'id'}) async {
    final db = await instance.database;
    final maps = await db!.query(
      table,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  // Listar todas as tabelas criadas
  Future<List<String>> listTables() async {
    final db = await instance.database;
    final result = await db!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
    );
    debugPrint("TABELAS CRIADAS: $result");
    return result.map((row) => row['name'] as String).toList();
  }

  // Diminuir a quantidade de materiais
  Future<void> diminuirMaterialQuantidade(int idMaterial, int quantity) async {
    final db = await instance.database;
    await db!.rawUpdate(
      'UPDATE materials SET quantity = quantity - ? WHERE id_material = ? AND quantity >= ?',
      [quantity, idMaterial, quantity]
    );
    debugPrint("Quantidade do material $idMaterial diminuída em $quantity.");
  }

  // Aumentar a quantidade de materiais
  Future<void> aumentarMaterialQuantidade(int idMaterial, int quantity) async {
    final db = await instance.database;
    await db!.rawUpdate(
      'UPDATE materials SET quantity = quantity + ? WHERE id_material = ?',
      [quantity, idMaterial]
    );
  }
/*
  // Verificar e associar alugos ao mesmo cliente
  Future<void> addOrUpdateAlugo(Map<String, dynamic> alugoData) async {
    final db = await instance.database;

    // Verificar se já existe um alugo para o mesmo cliente e material
    final existingAlugo = await db!.query(
      'alugos',
      where: 'name_alugador = ? AND nif_alugador = ? AND id_material = ?',
      whereArgs: [
        alugoData['name_alugador'],
        alugoData['nif_alugador'],
        alugoData['id_material']
      ],
    );

    if (existingAlugo.isNotEmpty) {
      // Atualizar o alugo existente
      final existingId = existingAlugo.first['id_alugo'];
      final newQuantity = existingAlugo.first['quantity'] + alugoData['quantity'];
      final newTotal = existingAlugo.first['total_alugo'] + alugoData['total_alugo'];

      await db.update(
        'alugos',
        {
          'quantity': newQuantity,
          'total_alugo': newTotal,
          'date_return': alugoData['date_return'], // Atualizar a data de devolução
        },
        where: 'id_alugo = ?',
        whereArgs: [existingId],
      );
    } else {
      // Inserir um novo alugo
      await insert('alugos', alugoData);
    }
  }*/
}