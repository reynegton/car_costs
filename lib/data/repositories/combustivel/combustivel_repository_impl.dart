// lib/repositories/combustivel_repository.dart

import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource.dart';
import 'package:car_costs/domain/repositories/combustivel/combustivel_repository.dart';
import '../../models/combustivel/combustivel.dart';


class CombustivelRepositoryImpl implements CombustivelRepository {
  final CombustivelLocalDatasource datasource;

  CombustivelRepositoryImpl({required this.datasource});
  

  // ----------------------------------------------------
  // Inicialização e Pré-cadastro
  // ----------------------------------------------------
  @override
  Future<void> initializeDefaultCombustiveis() async {
    return datasource.initializeDefaultCombustiveis();
  }

  // ----------------------------------------------------
  // R - READ (Listar Todos os Tipos)
  // ----------------------------------------------------
  @override
  Future<List<Combustivel>> getAllCombustiveis() async {
    return datasource.getAllCombustiveis();
  }

  // ----------------------------------------------------
  // R - READ (Listar IDs de Combustíveis Aceitos por um Veículo)
  // ----------------------------------------------------
  @override
  Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId) async {
    return datasource.getCombustivelIdsByVeiculo(veiculoId);
  }

  // ----------------------------------------------------
  // C/D - Sincronizar Combustíveis Aceitos
  // ----------------------------------------------------
  @override
  Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  ) async {
    await datasource.syncCombustiveisAceitos(veiculoId, combustivelIds);
  }
}
