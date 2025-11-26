import 'package:car_costs/core/database/database_helper.dart';
import 'package:car_costs/data/datasources/abastecimento/abastecimento_local_datasource.dart';
import 'package:car_costs/data/models/abastecimento/abastecimento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AbastecimentoLocalDatasourceImpl implements AbastecimentoLocalDatasource{
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Abastecimentos';
  
  @override
  Future<int> insertAbastecimento(Abastecimento abastecimento) async {
    final db = await _dbHelper.database;
    return await db.insert(
      _tableName,
      abastecimento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Abastecimento>> getAbastecimentosByVeiculo(int veiculoId) async {
    final db = await _dbHelper.database;

    // Filtra pelo veiculoId e ordena pelo KM mais recente
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'veiculoId = ?',
      whereArgs: [veiculoId],
      orderBy: 'data DESC,kmAtual DESC ', // Mais recente primeiro
    );

    // Converte a lista de Maps em uma lista de objetos Abastecimento
    return List.generate(maps.length, (i) {
      return Abastecimento.fromMap(maps[i]);
    });
  }

  @override
  Future<Abastecimento?> getLastFullTankAbastecimento(int veiculoId) async {
    final db = await _dbHelper.database;

    // Busca o abastecimento onde 'tanqueCheio = 1' (true)
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'veiculoId = ? AND tanqueCheio = 1',
      whereArgs: [veiculoId],
      orderBy: 'kmAtual DESC', // O que tem a maior KM
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Abastecimento.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Abastecimento>> getAbastecimentosByDateRange(
    int veiculoId,
    String startDate,
    String endDate,
  ) async {
    final db = await _dbHelper.database;

    // Filtra pelo veiculoId E pela data dentro do intervalo
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'veiculoId = ? AND data >= ? AND data <= ?',
      whereArgs: [veiculoId, startDate, endDate],
      orderBy: 'data DESC',
    );

    return List.generate(maps.length, (i) {
      return Abastecimento.fromMap(maps[i]);
    });
  }

  @override
  Future<int> updateAbastecimento(Abastecimento abastecimento) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      abastecimento.toMap(),
      where: 'id = ?',
      whereArgs: [abastecimento.id],
    );
  }

  @override
  Future<int> deleteAbastecimento(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}