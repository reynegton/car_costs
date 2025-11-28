// lib/repositories/veiculo_repository.dart

import 'package:car_costs/data/datasources/veiculo/veiculo_local_datasource.dart';
import 'package:car_costs/domain/repositories/veiculo/veiculo_repository.dart';

import '../../models/veiculo/veiculo.dart';

class VeiculoRepositoryImpl implements VeiculoRepository {
  final VeiculoLocalDatasource veiculoLocalDatasource;
  VeiculoRepositoryImpl({required this.veiculoLocalDatasource});

  // ----------------------------------------------------
  // CRUD: C - CREATE (Inserir Veículo)
  // ----------------------------------------------------
  @override
  Future<int> insertVeiculo(Veiculo veiculo, List<int> combustivelIds) async {
    return veiculoLocalDatasource.insertVeiculo(veiculo, combustivelIds);
  }

  // ----------------------------------------------------
  // R - READ (Obter Veículo por ID)
  // ----------------------------------------------------
  @override
  Future<Veiculo?> getVeiculoById(int id) async {
    return veiculoLocalDatasource.getVeiculoById(id);
  }

  // ----------------------------------------------------
  // CRUD: R - READ (Listar Todos os Veículos)
  // ----------------------------------------------------
  @override
  Future<List<Veiculo>> getVeiculos() async {
    return veiculoLocalDatasource.getVeiculos();
  }

  // ----------------------------------------------------
  // CRUD: U - UPDATE (Atualizar Veículo)
  // ----------------------------------------------------
  @override
  Future<int> updateVeiculo(Veiculo veiculo, List<int> combustivelIds) async {
    return veiculoLocalDatasource.updateVeiculo(veiculo, combustivelIds);
  }

  // ----------------------------------------------------
  // CRUD: D - DELETE (Deletar Veículo)
  // ----------------------------------------------------
  @override
  Future<int> deleteVeiculo(int id) async {
    return veiculoLocalDatasource.deleteVeiculo(id);
  }

  // ----------------------------------------------------
  // R - READ (Listar IDs de Combustíveis Aceitos por um Veículo)
  // ----------------------------------------------------
  @override
  Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId) async {
    return veiculoLocalDatasource.getCombustivelIdsByVeiculo(veiculoId);
  }

  // ----------------------------------------------------
  // C/D - Sincronizar Combustíveis Aceitos
  // ----------------------------------------------------
  @override
  Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  ) async {
    await veiculoLocalDatasource.syncCombustiveisAceitos(veiculoId, combustivelIds);
  }
}
