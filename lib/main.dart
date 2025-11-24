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
      child: SafeArea(
        child: MaterialApp(
          title: 'Fuel Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blueGrey,
            tabBarTheme: TabBarThemeData(
              // Cor do ícone/texto da aba SELECIONADA
              labelColor: Colors.blueGrey,

              // Cor do ícone/texto das abas NÃO SELECIONADAS
              unselectedLabelColor: Colors.blueGrey.shade200,

              // Cor da linha de destaque da aba (indicator)
              indicatorColor: Colors.blueGrey,
            ),
            switchTheme: SwitchThemeData(
              // Cor do polegar (thumb) quando ATIVO (ligado)
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  // Usa a cor primária (azul) quando ligado
                  return Colors.white;
                }
                // Cor do polegar quando DESLIGADO (cinza claro)
                return Colors.white;
              }),
              // Cor do trilho (track) quando ATIVO (ligado)
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  // Usa um tom mais claro ou acinzentado do azul quando ligado
                  return Colors.blueGrey;
                }
                // Cor do trilho quando DESLIGADO (cinza escuro)
                return Colors.blueGrey.shade100;
              }),
            ),
            chipTheme: ChipThemeData(
              // Cor de fundo do chip (quando não selecionado)
              backgroundColor: Colors.grey.shade200, 
              
              // Cor da borda
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),

              // Cor do rótulo (texto)
              labelStyle: TextStyle(color: Colors.grey.shade800),
              
              // Cor do background quando o chip está SELECIONADO (a mais importante)
              selectedColor: Colors.blueGrey.shade200, 

              // Cor do checkmark ou do ícone/texto quando SELECIONADO
              checkmarkColor: Colors.blue.shade900, 
              
              // Cor do rótulo quando SELECIONADO
              secondaryLabelStyle: const TextStyle(color: Colors.black),
              
              // Cor do ícone quando selecionado
              secondarySelectedColor: Colors.blue.shade900, 
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                // Cor do texto/ícone (já deve ser azul)
                foregroundColor: Colors.blueGrey, 
                
                // Cor do splash/overlay quando o usuário toca (EFEITO)
                
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                // Cor de fundo padrão: Usa a cor primária do tema (Azul)
                backgroundColor: Colors.blueGrey,

                // Cor do texto/ícone: Contraste branco
                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              // Cor de fundo do botão
              backgroundColor: Colors.blueGrey,

              // Cor dos ícones e texto (deve ser contrastante)
              foregroundColor: Colors.white,

              // Elevação do botão (sombra)
              elevation: 4,
            ),

            // ----------------------------------------------------
            // NOVO: CONFIGURAÇÃO GLOBAL DE TEXTFORMFIELD STYLE
            // ----------------------------------------------------
            inputDecorationTheme: InputDecorationTheme(
              // 1. Define a borda padrão como OutlineInputBorder
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ), // Bordas arredondadas (opcional)
              ),

              // 2. Define a borda quando o campo está habilitado (sem foco)
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              ),

              // 3. Define a borda quando o campo está focado (digitando)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),

              // 4. Se você usa prefixos/sufixos, ajuste o padding
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 10.0,
              ),

              // 5. Ajuste para o texto do label (opcional)
              labelStyle: TextStyle(color: Colors.grey.shade700),
            ),
            // ----------------------------------------------------
          ),
          home: const MainLoaderScreen(),
        ),
      ),
    );
  }
}
