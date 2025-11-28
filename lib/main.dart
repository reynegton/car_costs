// lib/main.dart - Adicionar ManutencaoBloc

import 'dart:io';

import 'package:car_costs/data/datasources/abastecimento/abastecimento_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/configuracao/configuracao_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/manutencao/manutencao_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/veiculo/veiculo_local_datasource_impl.dart';
import 'package:car_costs/presentation/blocs/combustivel/combustivel_bloc.dart';
import 'package:car_costs/presentation/blocs/relatorio/relatorio_bloc.dart';
import 'package:car_costs/data/repositories/combustivel/combustivel_repository_impl.dart';
import 'package:car_costs/data/repositories/configuracao/configuracao_repository_impl.dart';
import 'package:car_costs/main_loader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data/repositories/veiculo/veiculo_repository_impl.dart';
import 'data/repositories/abastecimento/abastecimento_repository.dart';
import 'data/repositories/manutencao/manutencao_repository_impl.dart'; // Importar
import 'presentation/blocs/veiculo/veiculo_bloc.dart';
import 'presentation/blocs/abastecimento/abastecimento_bloc.dart';
import 'presentation/blocs/manutencao/manutencao_bloc.dart'; // Importar
import 'package:flutter_localizations/flutter_localizations.dart'; 


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
    final veiculoLocalDatasource = VeiculoLocalDatasourceImpl();
    final manutencaoLocalDatasource = ManutencaoLocalDatasourceImpl();
    final configuracaoLocalDatasource = ConfiguracaoLocalDatasourceImpl();
    final veiculoRepository = VeiculoRepositoryImpl(
      veiculoLocalDatasource: veiculoLocalDatasource,
    );
    final abastecimentoRepository = AbastecimentoRepositoryImpl(localDatasource: AbastecimentoLocalDatasourceImpl());
    final manutencaoRepository = ManutencaoRepositoryImpl(manutencaoLocalDatasource: manutencaoLocalDatasource); // Instanciar
    final configuracaoRepository = ConfiguracaoRepositoryImpl(localDatasource: configuracaoLocalDatasource);
    final datasourceCombustiveis = CombustivelLocalDatasourceImpl();
    final combustivelRepository = CombustivelRepositoryImpl(datasource: datasourceCombustiveis);
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
              CombustivelBloc(combustivelRepository, veiculoRepository, configuracaoRepository),
        ),
      ],
      child: SafeArea(
        child: MaterialApp(
          title: 'Fuel Manager',
          debugShowCheckedModeBanner: false,
          // ----------------------------------------------------
        // NOVO: CONFIGURAÇÃO DE LOCALIZAÇÃO (IDIOMA)
        // ----------------------------------------------------
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Definimos o suporte apenas para o Português do Brasil
        supportedLocales: const [
          Locale('pt', 'BR'), 
        ],
        // Define o idioma padrão do app (se não conseguir determinar o do sistema)
        locale: const Locale('pt', 'BR'), 
        // ----------------------------------------------------
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

            colorScheme:
                ColorScheme.fromSwatch(
                  // Usa o azul como a cor principal do esquema
                  primarySwatch: Colors.blueGrey,

                  // Define a cor de destaque (seleção)
                  accentColor: Colors.blueAccent,
                ).copyWith(
                  // Sobrescreve a cor de superfície e a cor principal para o DatePicker
                  primary:
                      Colors.blue.shade700, // Cor do cabeçalho (Azul Escuro)
                  onPrimary: Colors.white, // Cor do texto/ícones no cabeçalho
                  surface: Colors.white, // Cor de fundo do calendário
                  onSurface: Colors.black, // Cor dos dias e texto
                  secondary: Colors.blue, // Cor do círculo de seleção
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

            sliderTheme: SliderThemeData(
              // Cor do 'thumb' (o controle redondo)
              thumbColor: Colors.blueGrey,

              // Cor da linha ativa (a parte entre o início e o thumb)
              activeTrackColor: Colors.blueGrey,

              // Cor da linha inativa (a parte entre o thumb e o final)
              inactiveTrackColor: Colors.blueGrey.shade300,

              // Cor do texto do 'label' (o valor que aparece quando arrasta, se habilitado)
              valueIndicatorColor: Colors.blueGrey.shade700,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
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
