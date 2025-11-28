// lib/repositories/manutencao_repository.dart

import 'package:car_costs/data/datasources/manutencao/manutencao_local_datasource.dart';

import '../../../core/database/database_helper.dart';
import '../../models/manutencao/manutencao.dart';
import 'package:sqflite/sqflite.dart';

class ManutencaoLocalDatasourceImpl implements ManutencaoLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Manutencoes';

  // ----------------------------------------------------
  // C - CREATE (Inserir Manutenção)
  // ----------------------------------------------------
  @override
  Future<int> insertManutencao(Manutencao manutencao) async {
    final db = await _dbHelper.database;
    return await db.insert(
      _tableName,
      manutencao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------
  // R - READ (Listar Manutenções de um Veículo)
  // ----------------------------------------------------
  @override
  Future<List<Manutencao>> getManutencoesByVeiculo(int veiculoId) async {
    final db = await _dbHelper.database;

    // Filtra pelo veiculoId e ordena pela data mais recente
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'veiculoId = ?',
      whereArgs: [veiculoId],
      orderBy: 'data DESC',
    );

    // Converte a lista de Maps em uma lista de objetos Manutencao
    return List.generate(maps.length, (i) {
      return Manutencao.fromMap(maps[i]);
    });
  }

  // ----------------------------------------------------
  // R - READ (Listar Manutenções por Data)
  // ----------------------------------------------------
  @override
  Future<List<Manutencao>> getManutencoesByDateRange(
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
      return Manutencao.fromMap(maps[i]);
    });
  }

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Manutenção)
  // ----------------------------------------------------
  @override
  Future<int> updateManutencao(Manutencao manutencao) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      manutencao.toMap(),
      where: 'id = ?',
      whereArgs: [manutencao.id],
    );
  }

  // ----------------------------------------------------
  // D - DELETE (Deletar Manutenção)
  // ----------------------------------------------------
  @override
  Future<int> deleteManutencao(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
