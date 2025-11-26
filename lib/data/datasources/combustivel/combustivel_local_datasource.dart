import 'package:car_costs/data/models/combustivel/combustivel.dart';

abstract class CombustivelLocalDatasource {

  Future<void> initializeDefaultCombustiveis();
   Future<List<Combustivel>> getAllCombustiveis();
   Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId);
   Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  );
}