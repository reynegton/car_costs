// lib/repositories/combustivel_repository.dart

import '../database/database_helper.dart';
import '../models/combustivel.dart';
import '../models/veiculo_combustivel.dart';
import 'package:sqflite/sqflite.dart';

class CombustivelRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Tipos predefinidos
  final List<String> _defaultCombustiveis = [
    'Etanol',
    'Gasolina',
    'Diesel',
    'GNV',
  ];

  // ----------------------------------------------------
  // Inicialização e Pré-cadastro
  // ----------------------------------------------------
  Future<void> initializeDefaultCombustiveis(Database db) async {
    for (var nome in _defaultCombustiveis) {
      // Verifica se o combustível já existe antes de inserir
      final List<Map<String, dynamic>> maps = await db.query(
        'Combustiveis',
        where: 'nome = ?',
        whereArgs: [nome],
      );
      if (maps.isEmpty) {
        await db.insert('Combustiveis', {'nome': nome});
      }
    }
  }

  // ----------------------------------------------------
  // R - READ (Listar Todos os Tipos)
  // ----------------------------------------------------
  Future<List<Combustivel>> getAllCombustiveis() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Combustiveis',
      orderBy: 'nome ASC',
    );
    return List.generate(maps.length, (i) => Combustivel.fromMap(maps[i]));
  }

  // ----------------------------------------------------
  // R - READ (Listar IDs de Combustíveis Aceitos por um Veículo)
  // ----------------------------------------------------
  Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'VeiculoCombustivel',
      columns: ['combustivelId'],
      where: 'veiculoId = ?',
      whereArgs: [veiculoId],
    );
    return maps.map((map) => map['combustivelId'] as int).toList();
  }

  // ----------------------------------------------------
  // C/D - Sincronizar Combustíveis Aceitos
  // ----------------------------------------------------
  Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  ) async {
    final db = await _dbHelper.database;

    // 1. Deleta todas as relações existentes para este veículo
    await db.delete(
      'VeiculoCombustivel',
      where: 'veiculoId = ?',
      whereArgs: [veiculoId],
    );

    // 2. Insere as novas relações
    final batch = db.batch();
    for (var id in combustivelIds) {
      batch.insert(
        'VeiculoCombustivel',
        VeiculoCombustivel(veiculoId: veiculoId, combustivelId: id).toMap(),
      );
    }
    await batch.commit();
  }
}
