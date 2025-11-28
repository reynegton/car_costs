import 'package:car_costs/core/database/database_helper.dart';

import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource.dart';
import 'package:car_costs/data/models/combustivel/combustivel.dart';


class CombustivelLocalDatasourceImpl implements CombustivelLocalDatasource{
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Combustiveis';
  
    // Tipos predefinidos
  final List<String> _defaultCombustiveis = [
    'Etanol',
    'Gasolina',
    'Diesel',
    'GNV',
  ];


  @override
  Future<void> initializeDefaultCombustiveis() async {
    final db = await _dbHelper.database;
    for (var nome in _defaultCombustiveis) {
      // Verifica se o combustível já existe antes de inserir
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'nome = ?',
        whereArgs: [nome],
      );
      if (maps.isEmpty) {
        await db.insert(_tableName,{'nome': nome});
      }
    }
  }

  @override
   Future<List<Combustivel>> getAllCombustiveis() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'nome ASC',
    );
    return List.generate(maps.length, (i) => Combustivel.fromMap(maps[i]));
  }

  
  
}