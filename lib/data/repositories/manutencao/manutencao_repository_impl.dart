// lib/repositories/manutencao_repository.dart

import 'package:car_costs/data/datasources/manutencao/manutencao_local_datasource.dart';
import 'package:car_costs/domain/repositories/manutencao/manutencao_repository.dart';
import '../../models/manutencao/manutencao.dart';


class ManutencaoRepositoryImpl implements ManutencaoRepository {
  final ManutencaoLocalDatasource manutencaoLocalDatasource;

  ManutencaoRepositoryImpl({required this.manutencaoLocalDatasource});

  // ----------------------------------------------------
  // C - CREATE (Inserir Manutenção)
  // ----------------------------------------------------
  @override
  Future<int> insertManutencao(Manutencao manutencao) async {
    return manutencaoLocalDatasource.insertManutencao(manutencao);
  }

  // ----------------------------------------------------
  // R - READ (Listar Manutenções de um Veículo)
  // ----------------------------------------------------
  @override
  Future<List<Manutencao>> getManutencoesByVeiculo(int veiculoId) async {
    return manutencaoLocalDatasource.getManutencoesByVeiculo(veiculoId);
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
    return manutencaoLocalDatasource.getManutencoesByDateRange(
      veiculoId,
      startDate,
      endDate,
    );
  }

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Manutenção)
  // ----------------------------------------------------
  @override
  Future<int> updateManutencao(Manutencao manutencao) async {
    return manutencaoLocalDatasource.updateManutencao(manutencao);
  }

  // ----------------------------------------------------
  // D - DELETE (Deletar Manutenção)
  // ----------------------------------------------------
  @override
  Future<int> deleteManutencao(int id) async {
    return manutencaoLocalDatasource.deleteManutencao(id);
  }
}
