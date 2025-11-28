// lib/screens/configuracao_dialog.dart

import 'package:car_costs/data/datasources/configuracao/configuracao_local_datasource_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/configuracao/configuracao_repository_impl.dart';
import '../../blocs/veiculo/veiculo_bloc.dart';
import '../../blocs/veiculo/veiculo_event.dart';

// Diálogo simples para configurar o N da Média Longo Prazo
class ConfiguracaoDialog extends StatefulWidget {
  const ConfiguracaoDialog({super.key});

  @override
  State<ConfiguracaoDialog> createState() => _ConfiguracaoDialogState();
}

class _ConfiguracaoDialogState extends State<ConfiguracaoDialog> {
  int _nValue = 3; // Valor padrão
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final repo = ConfiguracaoRepositoryImpl(localDatasource: ConfiguracaoLocalDatasourceImpl());
    final config = await repo.getConfiguracao();
    setState(() {
      _nValue = config.mediaApuracaoN;
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    final repo = ConfiguracaoRepositoryImpl(localDatasource: ConfiguracaoLocalDatasourceImpl());
    final config = await repo.getConfiguracao();
    config.mediaApuracaoN = _nValue;
    await repo.updateConfiguracao(config);

    if (mounted) {
      context.read<VeiculoBloc>().add(LoadVeiculos());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configuração da Média'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Média Longo Prazo: Número de Últimas Médias a Considerar (N)',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _nValue.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'N (Mínimo 1)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final n = int.tryParse(value);
                    if (n != null && n >= 1) {
                      setState(() {
                        _nValue = n;
                      });
                    }
                  },
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveConfig,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
