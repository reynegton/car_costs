
import 'package:car_costs/data/datasources/configuracao/configuracao_local_datasource.dart';

import '../../../core/database/database_helper.dart';
import '../../models/configuracao/configuracao.dart';

class ConfiguracaoLocalDatasourceImpl implements ConfiguracaoLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'Configuracoes';

  // ----------------------------------------------------
  // Inicialização (Garante que há um registro)
  // ----------------------------------------------------
  @override
  Future<Configuracao> getConfiguracao() async {
    final db = await _dbHelper.database;

    // Tenta ler o único registro (ID 1)
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Configuracao.fromMap(maps.first);
    } else {
      // Se não existir, cria o registro padrão e retorna ele
      final padrao = Configuracao();
      await db.insert(_tableName, padrao.toMap());
      return padrao;
    }
  }

  // ----------------------------------------------------
  // U - UPDATE (Atualizar Configuração)
  // ----------------------------------------------------
  @override
  Future<int> updateConfiguracao(Configuracao config) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      config.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ----------------------------------------------------
  // U - UPDATE (Salvar Veículo Selecionado)
  // ----------------------------------------------------
  @override
  Future<void> setVeiculoSelecionado(int veiculoId) async {
    final db = await _dbHelper.database;
    final config = await getConfiguracao(); // Busca a config atual

    config.veiculoIdSelecionado = veiculoId;

    await db.update(
      _tableName,
      config.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ----------------------------------------------------
  // R - READ (Obter Veículo Selecionado)
  // ----------------------------------------------------
  @override
  Future<int?> getVeiculoSelecionadoId() async {
    final config = await getConfiguracao();
    return config.veiculoIdSelecionado;
  }

  // ----------------------------------------------------
  // U - UPDATE (Salvar Último Combustível Usado)
  // ----------------------------------------------------
  @override
  Future<void> setUltimoCombustivelId(int combustivelId) async {
    final db = await _dbHelper.database;
    final config = await getConfiguracao();

    config.ultimoCombustivelId = combustivelId;

    await db.update(
      _tableName,
      config.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ----------------------------------------------------
  // R - READ (Obter Último Combustível Usado)
  // ----------------------------------------------------
  @override
  Future<int?> getUltimoCombustivelId() async {
    final config = await getConfiguracao();
    return config.ultimoCombustivelId;
  }

  // ----------------------------------------------------
  // U - UPDATE (Salvar se o último foi Tanque Cheio)
  // ----------------------------------------------------
  @override
  Future<void> setEncheuTanqueUltimoAbastecimento(bool isFullTank) async {
    final db = await _dbHelper.database;
    final config = await getConfiguracao(); 
    
    // Atualiza o valor no objeto
    config.encheuTanqueUltimoAbastecimento = isFullTank;
    
    // Salva no banco (o toMap() cuida da conversão bool -> int)
    await db.update(
      _tableName,
      config.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ----------------------------------------------------
  // R - READ (Obter Estado do Tanque Cheio para a UI)
  // ----------------------------------------------------
  @override
  Future<bool> getEncheuTanqueUltimoAbastecimento() async {
    final config = await getConfiguracao();
    return config.encheuTanqueUltimoAbastecimento; 
  }
}
