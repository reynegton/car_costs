// lib/repositories/manutencao_repository.dart


import '../../models/manutencao/manutencao.dart';


abstract class ManutencaoLocalDatasource{
  

  // ----------------------------------------------------
  // C - CREATE (Inserir Manutenção)
  // ----------------------------------------------------
  Future<int> insertManutencao(Manutencao manutencao) ;

  // ----------------------------------------------------
  // R - READ (Listar Manutenções de um Veículo)
  // ----------------------------------------------------
  Future<List<Manutencao>> getManutencoesByVeiculo(int veiculoId);

  // ----------------------------------------------------
  // R - READ (Listar Manutenções por Data)
  // ----------------------------------------------------
  Future<List<Manutencao>> getManutencoesByDateRange(
    int veiculoId,
    String startDate,
    String endDate,
  );

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Manutenção)
  // ----------------------------------------------------
  Future<int> updateManutencao(Manutencao manutencao);

  // ----------------------------------------------------
  // D - DELETE (Deletar Manutenção)
  // ----------------------------------------------------
  Future<int> deleteManutencao(int id);
}
