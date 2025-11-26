// lib/screens/main_loader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/veiculo.dart';
import '../repositories/configuracao_repository.dart';
import '../repositories/veiculo_repository.dart';
import '../blocs/veiculo/veiculo_bloc.dart';
import '../blocs/veiculo/veiculo_event.dart';
import 'veiculo_detail_screen.dart';
import 'veiculo_list_screen.dart';

class MainLoaderScreen extends StatefulWidget {
  const MainLoaderScreen({super.key});

  @override
  State<MainLoaderScreen> createState() => _MainLoaderScreenState();
}

class _MainLoaderScreenState extends State<MainLoaderScreen> {
  final _configRepo = ConfiguracaoRepository();
  final _veiculoRepo = VeiculoRepository();

  @override
  void initState() {
    super.initState();
    // Inicia a verificação do veículo após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkInitialRoute(context),
    );
  }

  Future<void> _checkInitialRoute(BuildContext context) async {
    // 1. Carregar a lista de veículos primeiro (necessário para o VeiculoBloc)
    context.read<VeiculoBloc>().add(LoadVeiculos());

    final int? selectedId = await _configRepo.getVeiculoSelecionadoId();

    if (selectedId != null) {
      // 2. Tenta obter os dados completos do veículo
      final Veiculo? veiculo = await _veiculoRepo.getVeiculoById(selectedId);

      if (veiculo != null && mounted) {
        // Se o veículo foi encontrado, navega para a tela de detalhes
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VeiculoDetailScreen(veiculo: veiculo),
            ),
          );
        }
        return;
      }
    }

    // 3. Se não houver veículo salvo ou se ele não existir mais,
    // navega para a lista de seleção.
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VeiculoListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento enquanto verifica a rota
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Carregando preferências..."),
          ],
        ),
      ),
    );
  }
}
