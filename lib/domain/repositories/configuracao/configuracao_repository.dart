// lib/repositories/configuracao_repository.dart

import 'package:car_costs/data/models/configuracao/configuracao.dart';

abstract class ConfiguracaoRepository {
  
  // ----------------------------------------------------
  // Inicialização (Garante que há um registro)
  // ----------------------------------------------------
  Future<Configuracao> getConfiguracao();

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Configuração)
  // ----------------------------------------------------
  Future<int> updateConfiguracao(Configuracao config);

  // ----------------------------------------------------
  // U - UPDATE (Salvar Veículo Selecionado)
  // ----------------------------------------------------
  Future<void> setVeiculoSelecionado(int veiculoId) ;

  // ----------------------------------------------------
  // R - READ (Obter Veículo Selecionado)
  // ----------------------------------------------------
  Future<int?> getVeiculoSelecionadoId();

  // ----------------------------------------------------
  // U - UPDATE (Salvar Último Combustível Usado)
  // ----------------------------------------------------
  Future<void> setUltimoCombustivelId(int combustivelId) ;

  // ----------------------------------------------------
  // R - READ (Obter Último Combustível Usado)
  // ----------------------------------------------------
  Future<int?> getUltimoCombustivelId();

  // ----------------------------------------------------
  // U - UPDATE (Salvar se o último foi Tanque Cheio)
  // ----------------------------------------------------
  Future<void> setEncheuTanqueUltimoAbastecimento(bool isFullTank);

  // ----------------------------------------------------
  // R - READ (Obter Estado do Tanque Cheio para a UI)
  // ----------------------------------------------------
  Future<bool> getEncheuTanqueUltimoAbastecimento();
}
