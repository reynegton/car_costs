// lib/repositories/abastecimento_repository.dart

import '../database/database_helper.dart';
import '../models/abastecimento.dart';
import 'package:sqflite/sqflite.dart';

class AbastecimentoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Abastecimentos';

  // ----------------------------------------------------
  // C - CREATE (Inserir Abastecimento)
  // ----------------------------------------------------
  Future<int> insertAbastecimento(Abastecimento abastecimento) async {
    final db = await _dbHelper.database;
    return await db.insert(
      _tableName,
      abastecimento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------
  // R - READ (Listar Abastecimentos de um Veículo)
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // R - READ (Obter o Último Abastecimento de Tanque Cheio)
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // R - READ (Listar Abastecimentos por Data)
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Abastecimento)
  // ----------------------------------------------------
  Future<int> updateAbastecimento(Abastecimento abastecimento) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      abastecimento.toMap(),
      where: 'id = ?',
      whereArgs: [abastecimento.id],
    );
  }

  // ----------------------------------------------------
  // D - DELETE (Deletar Abastecimento)
  // ----------------------------------------------------
  Future<int> deleteAbastecimento(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
