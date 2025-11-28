import 'package:car_costs/core/database/database_helper.dart';
import 'package:car_costs/data/datasources/veiculo/veiculo_local_datasource.dart';
import 'package:car_costs/data/models/veiculo/veiculo.dart';
import 'package:car_costs/data/models/veiculo/veiculo_combustivel.dart';
import 'package:sqflite/sqflite.dart';

class VeiculoLocalDatasourceImpl implements VeiculoLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Veiculos';
  final String _tableRelacionamento = 'VeiculoCombustivel';

 

  // ----------------------------------------------------
  // CRUD: C - CREATE (Inserir Veículo)
  // ----------------------------------------------------
  @override
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
    await syncCombustiveisAceitos(id, combustivelIds);

    return id;
  }

  // ----------------------------------------------------
  // R - READ (Obter Veículo por ID)
  // ----------------------------------------------------
  @override
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
      v.combustivelIdsAceitos = await getCombustivelIdsByVeiculo(v.id!);
      return v;
    }
    return null;
  }

  // ----------------------------------------------------
  // CRUD: R - READ (Listar Todos os Veículos)
  // ----------------------------------------------------
  @override
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
      veiculo.combustivelIdsAceitos = await getCombustivelIdsByVeiculo(veiculo.id!);
    }
    return v;
  }

  // ----------------------------------------------------
  // CRUD: U - UPDATE (Atualizar Veículo)
  // ----------------------------------------------------
  @override
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
    await syncCombustiveisAceitos(veiculo.id!, combustivelIds);

    return result;
  }

  // ----------------------------------------------------
  // CRUD: D - DELETE (Deletar Veículo)
  // ----------------------------------------------------
  @override
  Future<int> deleteVeiculo(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  
  @override
  Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableRelacionamento,
      columns: ['combustivelId'],
      where: 'veiculoId = ?',
      whereArgs: [veiculoId],
    );
    return maps.map((map) => map['combustivelId'] as int).toList();
  }

  
  @override
  Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  ) async {
    final db = await _dbHelper.database;

    // 1. Deleta todas as relações existentes para este veículo
    await db.delete(
      _tableRelacionamento,
      where: 'veiculoId = ?',
      whereArgs: [veiculoId],
    );

    // 2. Insere as novas relações
    final batch = db.batch();
    for (var id in combustivelIds) {
      batch.insert(
        _tableRelacionamento,
        VeiculoCombustivel(veiculoId: veiculoId, combustivelId: id).toMap(),
      );
    }
    await batch.commit();
  }
}