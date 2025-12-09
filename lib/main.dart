// lib/main.dart - Adicionar ManutencaoBloc

import 'dart:io';

import 'package:car_costs/data/datasources/abastecimento/abastecimento_local_datasource.dart';
import 'package:car_costs/data/datasources/abastecimento/abastecimento_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource.dart';
import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/configuracao/configuracao_local_datasource.dart';
import 'package:car_costs/data/datasources/configuracao/configuracao_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/manutencao/manutencao_local_datasource.dart';
import 'package:car_costs/data/datasources/manutencao/manutencao_local_datasource_impl.dart';
import 'package:car_costs/data/datasources/veiculo/veiculo_local_datasource.dart';
import 'package:car_costs/data/datasources/veiculo/veiculo_local_datasource_impl.dart';
import 'package:car_costs/domain/repositories/abastecimento/abastecimento_repository.dart';
import 'package:car_costs/domain/repositories/combustivel/combustivel_repository.dart';
import 'package:car_costs/domain/repositories/configuracao/configuracao_repository.dart';
import 'package:car_costs/domain/repositories/manutencao/manutencao_repository.dart';
import 'package:car_costs/domain/repositories/veiculo/veiculo_repository.dart';
import 'package:car_costs/presentation/blocs/combustivel/combustivel_bloc.dart';
import 'package:car_costs/presentation/blocs/relatorio/relatorio_bloc.dart';
import 'package:car_costs/data/repositories/combustivel/combustivel_repository_impl.dart';
import 'package:car_costs/data/repositories/configuracao/configuracao_repository_impl.dart';
import 'package:car_costs/main_loader_screen.dart';
import 'package:car_costs/core/app_colors.dart';
import 'package:car_costs/core/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(),
        ),
        Provider<VeiculoLocalDatasource>(create: (context) => VeiculoLocalDatasourceImpl()),
        Provider<ManutencaoLocalDatasource>(create: (context) => ManutencaoLocalDatasourceImpl()),
        Provider<ConfiguracaoLocalDatasource>(create: (context) => ConfiguracaoLocalDatasourceImpl()),
        Provider<AbastecimentoLocalDatasource>(create: (context) => AbastecimentoLocalDatasourceImpl()),
        Provider<CombustivelLocalDatasource>(create: (context) => CombustivelLocalDatasourceImpl()),

        ProxyProvider<VeiculoLocalDatasource, VeiculoRepository>(
          update: (context, local, previous) =>
              (previous != null)
                  ? previous
                  : VeiculoRepositoryImpl(
                      veiculoLocalDatasource: local,
                    ),
        ),

        ProxyProvider<AbastecimentoLocalDatasource, AbastecimentoRepository>(
          update: (context, local, previous) =>
              (previous != null)
                  ? previous
                  : AbastecimentoRepositoryImpl(
                      localDatasource: local,
                    ),
        ),

        ProxyProvider<ConfiguracaoLocalDatasource, ConfiguracaoRepository>(
          update: (context, local, previous) =>
              (previous != null)
                  ? previous
                  : ConfiguracaoRepositoryImpl(
                      localDatasource: local,
                    ),
        ),

        ProxyProvider<ManutencaoLocalDatasource, ManutencaoRepository>(
          update: (context, local, previous) =>
              (previous != null)
                  ? previous
                  : ManutencaoRepositoryImpl(
                      manutencaoLocalDatasource: local,
                    ),
        ),

        ProxyProvider<CombustivelLocalDatasource, CombustivelRepository>(
          update: (context, local, previous) =>
              (previous != null)
                  ? previous
                  : CombustivelRepositoryImpl(
                      datasource: local,
                    ),
        ),
        
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoC de Veículo
          BlocProvider(create: (context) => VeiculoBloc(context.read())),
          // BLoC de Abastecimento
          BlocProvider(
            create: (context) => AbastecimentoBloc(
              context.read(),
              context.read(),
              context.read(),
            ),
          ),
          // BLoC de Manutenção (NOVO)
          BlocProvider(create: (context) => ManutencaoBloc(context.read())),
          // BLoC de Relatório (NOVO)
          BlocProvider(
            create: (context) =>
                RelatorioBloc(context.read(), context.read()),
          ),
          BlocProvider(
            create: (context) =>
                CombustivelBloc(context.read(), context.read(), context.read()),
          ),
        ],
        child: SafeArea(
          child: Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return MaterialApp(
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
              primarySwatch: AppColors.primarySwatch,
              primaryColor: AppColors.primary,
              tabBarTheme: TabBarThemeData(
                // Cor do ícone/texto da aba SELECIONADA
                labelColor: AppColors.primary,
      
                // Cor do ícone/texto das abas NÃO SELECIONADAS
                unselectedLabelColor: AppColors.chipSelected,
      
                // Cor da linha de destaque da aba (indicator)
                indicatorColor: AppColors.primary,
              ),
      
              colorScheme:
                  ColorScheme.fromSwatch(
                    // Usa o azul como a cor principal do esquema
                    primarySwatch: AppColors.primarySwatch,
      
                    // Define a cor de destaque (seleção)
                    accentColor: AppColors.accent,
                  ).copyWith(
                    // Sobrescreve a cor de superfície e a cor principal para o DatePicker
                    primary: AppColors.primaryVariant, // Cor do cabeçalho (Azul Escuro)
                    onPrimary: AppColors.textOnPrimary, // Cor do texto/ícones no cabeçalho
                    surface: AppColors.surface, // Cor de fundo do calendário
                    onSurface: AppColors.textPrimary, // Cor dos dias e texto
                    secondary: AppColors.info, // Cor do círculo de seleção
                  ),
              switchTheme: SwitchThemeData(
                // Cor do polegar (thumb) quando ATIVO (ligado)
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    // Usa a cor primária (azul) quando ligado
                    return AppColors.white;
                  }
                  // Cor do polegar quando DESLIGADO (cinza claro)
                  return AppColors.white;
                }),
                // Cor do trilho (track) quando ATIVO (ligado)
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    // Usa um tom mais claro ou acinzentado do azul quando ligado
                    return AppColors.primary;
                  }
                  // Cor do trilho quando DESLIGADO (cinza escuro)
                  return AppColors.primaryTrackDisabled;
                }),
              ),
              chipTheme: ChipThemeData(
                // Cor de fundo do chip (quando não selecionado)
                backgroundColor: AppColors.chipBackground,
      
                // Cor da borda
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
      
                // Cor do rótulo (texto)
                labelStyle: TextStyle(color: AppColors.chipLabel),
      
                // Cor do background quando o chip está SELECIONADO (a mais importante)
                selectedColor: AppColors.chipSelected,
      
                // Cor do checkmark ou do ícone/texto quando SELECIONADO
                checkmarkColor: AppColors.chipCheckmark,
      
                // Cor do rótulo quando SELECIONADO
                secondaryLabelStyle: const TextStyle(color: AppColors.textPrimary),
      
                // Cor do ícone quando selecionado
                secondarySelectedColor: AppColors.chipCheckmark,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  // Cor do texto/ícone (já deve ser azul)
                  foregroundColor: AppColors.primary,
      
                  // Cor do splash/overlay quando o usuário toca (EFEITO)
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  // Cor de fundo padrão: Usa a cor primária do tema (Azul)
                  backgroundColor: AppColors.primary,
      
                  // Cor do texto/ícone: Contraste branco
                  foregroundColor: AppColors.textOnPrimary,
      
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
      
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                // Cor de fundo do botão
                backgroundColor: AppColors.primary,
      
                // Cor dos ícones e texto (deve ser contrastante)
                foregroundColor: AppColors.textOnPrimary,
      
                // Elevação do botão (sombra)
                elevation: 4,
              ),
      
              sliderTheme: SliderThemeData(
                // Cor do 'thumb' (o controle redondo)
                thumbColor: AppColors.primary,
      
                // Cor da linha ativa (a parte entre o início e o thumb)
                activeTrackColor: AppColors.primary,
      
                // Cor da linha inativa (a parte entre o thumb e o final)
                inactiveTrackColor: AppColors.sliderInactiveTrack,
      
                // Cor do texto do 'label' (o valor que aparece quando arrasta, se habilitado)
                valueIndicatorColor: AppColors.sliderValueIndicator,
                valueIndicatorTextStyle: const TextStyle(color: AppColors.textOnPrimary),
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
                  borderSide: BorderSide(color: AppColors.inputBorder, width: 1.0),
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
                labelStyle: TextStyle(color: AppColors.inputLabel),
              ),
              // ----------------------------------------------------
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: AppColors.primarySwatch,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              colorScheme: ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.info,
                surface: AppColors.surfaceDark,
                background: AppColors.backgroundDark,
                onPrimary: AppColors.textOnPrimary,
                onSecondary: AppColors.textPrimaryDark,
                onSurface: AppColors.textPrimaryDark,
              ),
              textTheme: ThemeData.dark().textTheme.apply(
                    bodyColor: AppColors.textPrimaryDark,
                    displayColor: AppColors.textPrimaryDark,
                  ),
              chipTheme: ThemeData.dark().chipTheme.copyWith(
                    backgroundColor: AppColors.surfaceDark,
                    selectedColor: AppColors.primary,
                    labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
                    secondaryLabelStyle:
                        const TextStyle(color: AppColors.textPrimaryDark),
                  ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
            themeMode: themeController.themeMode,
            home: Builder(
              builder: (newContext) {
                return MainLoaderScreen(configRepo: newContext.read(), veiculoRepo: newContext.read());
              }
            ),
          );
            },
          ),
        ),
      ),
    );
  }
}
