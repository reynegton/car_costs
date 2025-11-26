import 'package:car_costs/data/models/abastecimento/abastecimento.dart';

abstract class AbastecimentoLocalDatasource {
  Future<int> insertAbastecimento(Abastecimento abastecimento);
  Future<List<Abastecimento>> getAbastecimentosByVeiculo(int veiculoId);
  Future<Abastecimento?> getLastFullTankAbastecimento(int veiculoId);
  Future<List<Abastecimento>> getAbastecimentosByDateRange(
    int veiculoId,
    String startDate,
    String endDate,
  );
  Future<int> updateAbastecimento(Abastecimento abastecimento);
  Future<int> deleteAbastecimento(int id);
}