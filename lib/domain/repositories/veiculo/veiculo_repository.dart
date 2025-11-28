import 'package:car_costs/data/models/veiculo/veiculo.dart';

abstract class VeiculoRepository {
  

  // ----------------------------------------------------
  // CRUD: C - CREATE (Inserir Veículo)
  // ----------------------------------------------------
  Future<int> insertVeiculo(Veiculo veiculo, List<int> combustivelIds);

  // ----------------------------------------------------
  // R - READ (Obter Veículo por ID)
  // ----------------------------------------------------
  Future<Veiculo?> getVeiculoById(int id);

  // ----------------------------------------------------
  // CRUD: R - READ (Listar Todos os Veículos)
  // ----------------------------------------------------
  Future<List<Veiculo>> getVeiculos();

  // ----------------------------------------------------
  // CRUD: U - UPDATE (Atualizar Veículo)
  // ----------------------------------------------------
  // Modificar updateVeiculo para sincronizar as relações
  Future<int> updateVeiculo(Veiculo veiculo, List<int> combustivelIds);

  // ----------------------------------------------------
  // CRUD: D - DELETE (Deletar Veículo)
  // ----------------------------------------------------
  Future<int> deleteVeiculo(int id);

  // ----------------------------------------------------
  // R - READ (Listar IDs de Combustíveis Aceitos por um Veículo)
  // ----------------------------------------------------
  Future<List<int>> getCombustivelIdsByVeiculo(int veiculoId);

  // ----------------------------------------------------
  // C/D - Sincronizar Combustíveis Aceitos
  // ----------------------------------------------------
  Future<void> syncCombustiveisAceitos(
    int veiculoId,
    List<int> combustivelIds,
  );
}
