// lib/repositories/veiculo_repository.dart

import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource_impl.dart';
import 'package:car_costs/data/repositories/combustivel/combustivel_repository_impl.dart';
import 'package:car_costs/domain/repositories/combustivel/combustivel_repository.dart';

import '../../core/database/database_helper.dart';
import '../models/veiculo.dart';
import 'package:sqflite/sqflite.dart';

class VeiculoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Veiculos';
  final CombustivelRepository _combustivelRepo =
      CombustivelRepositoryImpl(datasource: CombustivelLocalDatasourceImpl()); // NOVO

  // ----------------------------------------------------
  // CRUD: C - CREATE (Inserir Veículo)
  // ----------------------------------------------------
  Future<int> insertVeiculo(Veiculo veiculo, List<int> combustivelIds) async {
    // NOVO PARÂMETRO
    final db = await _dbHelper.database;

    // Inserir o veículo
    final id = await db.insert(
      _tableName,
      veiculo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Sincronizar os combustíveis aceitos
    await _combustivelRepo.syncCombustiveisAceitos(id, combustivelIds);

    return id;
  }

  // ----------------------------------------------------
  // R - READ (Obter Veículo por ID)
  // ----------------------------------------------------
  Future<Veiculo?> getVeiculoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      var v = Veiculo.fromMap(maps.first);
      // Preencher o campo combustivelIdsAceitos
      v.combustivelIdsAceitos = await _combustivelRepo
          .getCombustivelIdsByVeiculo(v.id!);
      return v;
    }
    return null;
  }

  // ----------------------------------------------------
  // CRUD: R - READ (Listar Todos os Veículos)
  // ----------------------------------------------------
  Future<List<Veiculo>> getVeiculos() async {
    final db = await _dbHelper.database;
    // Consulta todos os veículos ordenados por nome
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'nome ASC',
    );

    // Converte a lista de Maps em uma lista de objetos Veiculo
    List<Veiculo> v = List.generate(maps.length, (i) {
      return Veiculo.fromMap(maps[i]);
    });
    // Preencher o campo combustivelIdsAceitos para cada veículo
    for (var veiculo in v) {
      veiculo.combustivelIdsAceitos = await _combustivelRepo
          .getCombustivelIdsByVeiculo(veiculo.id!);
    }
    return v;
  }

  // ----------------------------------------------------
  // CRUD: U - UPDATE (Atualizar Veículo)
  // ----------------------------------------------------
  // Modificar updateVeiculo para sincronizar as relações
  Future<int> updateVeiculo(Veiculo veiculo, List<int> combustivelIds) async {
    // NOVO PARÂMETRO
    final db = await _dbHelper.database;

    // Atualizar o veículo
    final result = await db.update(
      _tableName,
      veiculo.toMap(),
      where: 'id = ?',
      whereArgs: [veiculo.id],
    );

    // Sincronizar os combustíveis aceitos
    await _combustivelRepo.syncCombustiveisAceitos(veiculo.id!, combustivelIds);

    return result;
  }

  // ----------------------------------------------------
  // CRUD: D - DELETE (Deletar Veículo)
  // ----------------------------------------------------
  Future<int> deleteVeiculo(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
