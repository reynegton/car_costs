// lib/repositories/abastecimento_repository.dart

import 'package:car_costs/data/datasources/abastecimento/abastecimento_local_datasource.dart';
import 'package:car_costs/domain/repositories/abastecimento/abastecimento_repository.dart';


import '../../models/abastecimento/abastecimento.dart';


class AbastecimentoRepositoryImpl implements AbastecimentoRepository {
  final AbastecimentoLocalDatasource localDatasource;

  AbastecimentoRepositoryImpl({required this.localDatasource});

  // ----------------------------------------------------
  // C - CREATE (Inserir Abastecimento)
  // ----------------------------------------------------
  @override
  Future<int> insertAbastecimento(Abastecimento abastecimento) async {
    return localDatasource.insertAbastecimento(abastecimento);
  }

  // ----------------------------------------------------
  // R - READ (Listar Abastecimentos de um Veículo)
  // ----------------------------------------------------
  @override
  Future<List<Abastecimento>> getAbastecimentosByVeiculo(int veiculoId) async {
    return localDatasource.getAbastecimentosByVeiculo(veiculoId);
  }

  // ----------------------------------------------------
  // R - READ (Obter o Último Abastecimento de Tanque Cheio)
  // ----------------------------------------------------
  @override
  Future<Abastecimento?> getLastFullTankAbastecimento(int veiculoId) async {
    return localDatasource.getLastFullTankAbastecimento(veiculoId);
  }

  // ----------------------------------------------------
  // R - READ (Listar Abastecimentos por Data)
  // ----------------------------------------------------
  @override
  Future<List<Abastecimento>> getAbastecimentosByDateRange(
    int veiculoId,
    String startDate,
    String endDate,
  ) async {
    return localDatasource.getAbastecimentosByDateRange(veiculoId, startDate, endDate);
  }

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Abastecimento)
  // ----------------------------------------------------
  @override
  Future<int> updateAbastecimento(Abastecimento abastecimento) async {
    return localDatasource.updateAbastecimento(abastecimento);
  }

  // ----------------------------------------------------
  // D - DELETE (Deletar Abastecimento)
  // ----------------------------------------------------
  @override
  Future<int> deleteAbastecimento(int id) async {
    return localDatasource.deleteAbastecimento(id);
  }
}
