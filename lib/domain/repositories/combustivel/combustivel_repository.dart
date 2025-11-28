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

}
