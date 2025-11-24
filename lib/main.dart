// lib/main.dart - Adicionar ManutencaoBloc

import 'dart:io';

import 'package:car_costs/blocs/combustivel/combustivel_bloc.dart';
import 'package:car_costs/blocs/relatorio/relatorio_bloc.dart';
import 'package:car_costs/repositories/combustivel_repository.dart';
import 'package:car_costs/repositories/configuracao_repository.dart';
import 'package:car_costs/screens/main_loader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'repositories/veiculo_repository.dart';
import 'repositories/abastecimento_repository.dart';
import 'repositories/manutencao_repository.dart'; // Importar
import 'blocs/veiculo/veiculo_bloc.dart';
import 'blocs/abastecimento/abastecimento_bloc.dart';
import 'blocs/manutencao/manutencao_bloc.dart'; // Importar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Inicializa o sqflite FFI (Foreign Function Interface) para Desktop
    sqfliteFfiInit();
    // Define o databaseFactory para usar o FFI em Desktop
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const FuelManagerApp());
}

class FuelManagerApp extends StatelessWidget {
  const FuelManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Instanciar Repositórios
    final veiculoRepository = VeiculoRepository();
    final abastecimentoRepository = AbastecimentoRepository();
    final manutencaoRepository = ManutencaoRepository(); // Instanciar
    final configuracaoRepository = ConfiguracaoRepository();
    return MultiBlocProvider(
      providers: [
        // BLoC de Veículo
        BlocProvider(create: (context) => VeiculoBloc(veiculoRepository)),
        // BLoC de Abastecimento
        BlocProvider(
          create: (context) => AbastecimentoBloc(
            abastecimentoRepository,
            veiculoRepository,
            configuracaoRepository,
          ),
        ),
        // BLoC de Manutenção (NOVO)
        BlocProvider(create: (context) => ManutencaoBloc(manutencaoRepository)),
        // BLoC de Relatório (NOVO)
        BlocProvider(
          create: (context) =>
              RelatorioBloc(abastecimentoRepository, manutencaoRepository),
        ),
        BlocProvider(
          create: (context) =>
              CombustivelBloc(CombustivelRepository(), configuracaoRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Fuel Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          
          // ----------------------------------------------------
          // NOVO: CONFIGURAÇÃO GLOBAL DE TEXTFORMFIELD STYLE
          // ----------------------------------------------------
          inputDecorationTheme: InputDecorationTheme(
            // 1. Define a borda padrão como OutlineInputBorder
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)), // Bordas arredondadas (opcional)
            ),
            
            // 2. Define a borda quando o campo está habilitado (sem foco)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            
            // 3. Define a borda quando o campo está focado (digitando)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            ),
            
            // 4. Se você usa prefixos/sufixos, ajuste o padding
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            
            // 5. Ajuste para o texto do label (opcional)
            labelStyle: TextStyle(color: Colors.grey.shade700),
          ),
          // ----------------------------------------------------
        ),
        home: const MainLoaderScreen(),
      ),
    );
  }
}
