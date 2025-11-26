// lib/repositories/combustivel_repository.dart

import 'package:car_costs/data/models/combustivel/combustivel.dart';

abstract class CombustivelRepository {
  
  // ----------------------------------------------------
  // Inicialização e Pré-cadastro
  // ----------------------------------------------------
  Future<void> initializeDefaultCombustiveis() ;

  // ----------------------------------------------------
  // R - READ (Listar Todos os Tipos)
  // ----------------------------------------------------
  Future<List<Combustivel>> getAllCombustiveis();

  // ----------------------------------------------------
  // R - READ (Listar IDs de Combustíveis Aceitos por um Veículo)
  // ----------------------------------------------------
  Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId) ;

  // ----------------------------------------------------
  // C/D - Sincronizar Combustíveis Aceitos
  // ----------------------------------------------------
  Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  );
}
