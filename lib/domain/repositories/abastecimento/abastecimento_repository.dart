// lib/repositories/abastecimento_repository.dart


import '../../../data/models/abastecimento/abastecimento.dart';

abstract class AbastecimentoRepository {
  

  // ----------------------------------------------------
  // C - CREATE (Inserir Abastecimento)
  // ----------------------------------------------------
  Future<int> insertAbastecimento(Abastecimento abastecimento);

  // ----------------------------------------------------
  // R - READ (Listar Abastecimentos de um Veículo)
  // ----------------------------------------------------
  Future<List<Abastecimento>> getAbastecimentosByVeiculo(int veiculoId) ;

  // ----------------------------------------------------
  // R - READ (Obter o Último Abastecimento de Tanque Cheio)
  // ----------------------------------------------------
  Future<Abastecimento?> getLastFullTankAbastecimento(int veiculoId) ;

  // ----------------------------------------------------
  // R - READ (Listar Abastecimentos por Data)
  // ----------------------------------------------------
  Future<List<Abastecimento>> getAbastecimentosByDateRange(
    int veiculoId,
    String startDate,
    String endDate,
  );

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Abastecimento)
  // ----------------------------------------------------
  Future<int> updateAbastecimento(Abastecimento abastecimento);

  // ----------------------------------------------------
  // D - DELETE (Deletar Abastecimento)
  // ----------------------------------------------------
  Future<int> deleteAbastecimento(int id) ;
}
