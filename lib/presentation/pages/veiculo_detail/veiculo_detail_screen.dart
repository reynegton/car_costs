// lib/screens/veiculo_detail_screen.dart

import 'package:car_costs/core/currency_input_format.dart';
import 'package:car_costs/core/app_colors.dart';
import 'package:car_costs/presentation/pages/relatorio/relatorio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_costs/core/theme_controller.dart';
import '../../../data/models/veiculo/veiculo.dart';
import '../../blocs/veiculo/veiculo_bloc.dart';
import '../../blocs/veiculo/veiculo_state.dart';
import '../../blocs/veiculo/veiculo_event.dart';
import '../../blocs/abastecimento/abastecimento_bloc.dart';
import '../../blocs/abastecimento/abastecimento_event.dart';
import '../../blocs/abastecimento/abastecimento_state.dart';
import '../abastecimento/abastecimento_form_screen.dart';
import '../manutencao/manutencao_screen.dart';
import '../manutencao/manutencao_form_screen.dart'; // Necessário para o FAB da aba Manutenções
import 'widgets/veiculo_detail_drawer_widgets.dart';
import 'widgets/veiculo_detail_dashboard_widgets.dart';
import 'widgets/veiculo_detail_abastecimento_widgets.dart';

// 1. CONVERTIDO PARA STATEFUL WIDGET PARA RASTREAR A ABA
class VeiculoDetailScreen extends StatefulWidget {
  final Veiculo veiculo;

  const VeiculoDetailScreen({super.key, required this.veiculo});

  @override
  State<VeiculoDetailScreen> createState() => _VeiculoDetailScreenState();
}

class _VeiculoDetailScreenState extends State<VeiculoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // 0 = Dashboard, 1 = Manutenções

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // Helper para obter o Veiculo mais recente do BLoC
  Veiculo _getCurrentVeiculo(BuildContext context) {
    final state = context.read<VeiculoBloc>().state;
    if (state is VeiculoLoaded) {
      try {
        // Tenta encontrar a versão mais recente do veículo
        return state.veiculos.firstWhere((v) => v.id == widget.veiculo.id);
      } catch (_) {
        // Se não encontrar, retorna o objeto inicial
      }
    }
    return widget.veiculo;
  }

  // LÓGICA DO FAB DINÂMICO
  Widget? _buildFab(BuildContext context) {
    final currentVeiculo = _getCurrentVeiculo(context);

    if (_currentIndex == 0) {
      // Aba Dashboard: Novo Abastecimento
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AbastecimentoFormScreen(veiculo: currentVeiculo),
            ),
          );
        },
        icon: const Icon(Icons.local_gas_station),
        label: const Text('Novo Abastecimento'),
      );
    } else if (_currentIndex == 1) {
      // Aba Manutenções: Nova Manutenção
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ManutencaoFormScreen(veiculo: currentVeiculo),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Manutenção'),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    context.read<AbastecimentoBloc>().add(
      LoadAbastecimentos(widget.veiculo.id!),
    );

    final currentVeiculo = _getCurrentVeiculo(context);

    return BlocListener<VeiculoBloc, VeiculoState>(
      listener: (context, state) {
        // Nada de especial, apenas ouvindo para reatividade
      },
      child: BlocListener<AbastecimentoBloc, AbastecimentoState>(
        listener: (context, state) {
          if (state is AbastecimentoLoaded) {
            context.read<VeiculoBloc>().add(LoadVeiculos());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Gerenciamento: ${currentVeiculo.nome}'),
            centerTitle: true,
            actions: [
              // NOVO: Botão de Relatórios
              IconButton(
                icon: const Icon(Icons.assessment),
                tooltip: 'Relatórios de Gastos',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          RelatorioScreen(veiculo: currentVeiculo),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.handyman), text: 'Manutenções'),
              ],
            ),
          ),
          drawer: _buildDrawer(context),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ABA 1: DASHBOARD
              _buildDashboardTab(context, currentVeiculo),

              // ABA 2: MANUTENÇÕES (Sem FAB interno)
              ManutencaoScreen(veiculo: currentVeiculo, showFab: false),
            ],
          ),

          // FAB DINÂMICO CONTROLADO PELA ABA ATIVA
          floatingActionButton: _buildFab(context),
        ),
      ),
    );
  }

  // lib/screens/veiculo_detail_screen.dart (NOVO MÉTODO _buildDrawer)

  // ----------------------------------------------------
  // Menu Drawer para Troca de Veículo
  // ----------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
    // Usamos o VeiculoBloc para obter a lista de todos os veículos
    return Drawer(
      child: BlocBuilder<VeiculoBloc, VeiculoState>(
        builder: (context, state) {
          List<Veiculo> allVeiculos = [];
          if (state is VeiculoLoaded) {
            allVeiculos = state.veiculos;
          }

          final currentVeiculo = _getCurrentVeiculo(context);
          final themeController = context.watch<ThemeController>();
          final currentMode = themeController.themeMode;

          return Column(
            children: [
              buildDrawerHeader(context, currentVeiculo),
              Expanded(
                child: buildDrawerVeiculoList(
                  context,
                  allVeiculos,
                  currentVeiculo,
                ),
              ),
              const Divider(),
              buildDrawerThemeSection(
                context,
                themeController,
                currentMode,
              ),
              const Divider(),
              buildDrawerManageVeiculosTile(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, Veiculo veiculo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardCard(context, veiculo),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Histórico de Abastecimentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildAbastecimentoList(context, veiculo.id!),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // Widget: Dashboard Card (KM, Média, Nível)
  // -----------------------------------------------------------------
  Widget _buildDashboardCard(BuildContext context, Veiculo initialVeiculo) {
    return BlocBuilder<VeiculoBloc, VeiculoState>(
      buildWhen: (previous, current) => current is VeiculoLoaded,
      builder: (context, state) {
        Veiculo currentVeiculo = initialVeiculo;

        if (state is VeiculoLoaded) {
          try {
            currentVeiculo = state.veiculos.firstWhere(
              (v) => v.id == initialVeiculo.id,
            );
          } catch (_) {}
        }

        // --- CÁLCULO DE ESTIMATIVA DO NÍVEL ATUAL ---
        double nivelEstimadoLitros = currentVeiculo.litrosNoTanque;

        if (currentVeiculo.mediaManual > 0 &&
            currentVeiculo.kmAtual > currentVeiculo.kmUltimoNivel) {
          final kmRodada =
              currentVeiculo.kmAtual - currentVeiculo.kmUltimoNivel;
          final litrosGastosEstimados = kmRodada / currentVeiculo.mediaManual;

          nivelEstimadoLitros =
              currentVeiculo.litrosNoTanque - litrosGastosEstimados;

          if (nivelEstimadoLitros < 0) nivelEstimadoLitros = 0.0;
        }

        // --- NOVO: CÁLCULO DA AUTONOMIA ---
        double autonomiaUltimaMedia =
            nivelEstimadoLitros * currentVeiculo.mediaManual;
        double autonomiaLongoPrazo =
            nivelEstimadoLitros * currentVeiculo.mediaLongPrazo;

        double nivelPercentual =
            nivelEstimadoLitros / currentVeiculo.capacidadeTanqueLitros;
        if (nivelPercentual > 1.0) nivelPercentual = 1.0;
        if (nivelPercentual < 0.0) nivelPercentual = 0.0;
        // -----------------------------------------------------------

        return Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentVeiculo.nome,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),

                buildKmAtualRow(
                  context,
                  currentVeiculo,
                  () => _showKmEditDialog(context, currentVeiculo),
                ),
                const SizedBox(height: 10),

                buildMediaSection(
                  context,
                  currentVeiculo,
                  autonomiaUltimaMedia,
                ),
                const SizedBox(height: 10), // Espaçamento extra

                buildMediaLongoPrazoSection(
                  context,
                  currentVeiculo,
                  autonomiaLongoPrazo,
                ),

                buildNivelSection(
                  context,
                  currentVeiculo,
                  nivelEstimadoLitros,
                  nivelPercentual,
                  () => _showNivelEditDialog(
                    context,
                    currentVeiculo,
                    nivelEstimadoLitros,
                  ),
                ),
                const SizedBox(height: 5),

                buildNivelProgressBar(context, nivelPercentual),
                // Rótulos na Base (Opcional, mas altamente recomendado para clareza)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 0), // Posição 0%
                    Text('1/4',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.greyDark)),
                    Text('1/2',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.greyDark)),
                    Text('3/4',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.greyDark)),
                    SizedBox(width: 0), // Posição 100%
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // Widget: Lista de Abastecimentos
  // -----------------------------------------------------------------
  Widget _buildAbastecimentoList(BuildContext context, int veiculoId) {
    return BlocBuilder<AbastecimentoBloc, AbastecimentoState>(
      builder: (context, state) {
        if (state is AbastecimentoLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AbastecimentoError) {
          return Center(
            child: Text('Erro ao carregar histórico: ${state.message}'),
          );
        }

        if (state is AbastecimentoLoaded) {
          return buildAbastecimentoLoadedBody(
            context,
            state,
            veiculoId,
            (abastecimentoId, selectedVeiculoId) =>
                _confirmDeleteAbastecimento(
              context,
              abastecimentoId,
              selectedVeiculoId,
            ),
          );
        }
        return Container();
      },
    );
  }

  // -----------------------------------------------------------------
  // Diálogo para ajustar KM (APENAS KM)
  // -----------------------------------------------------------------
  // lib/screens/veiculo_detail_screen.dart (DENTRO do método _showKmEditDialog)

  void _showKmEditDialog(BuildContext context, Veiculo veiculo) {
    final kmController = TextEditingController(
      text: veiculo.kmAtual.toString(),
    );
    final kmRodadaController =
        TextEditingController(); // NOVO: Campo para KM Rodada

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          // Necessário para atualizar o campo KM Atual ao somar
          builder: (context, setStateSB) {
            // Função auxiliar para somar N km ao KM Atual salvo
            void somarKms() {
              final kmRodada = int.tryParse(kmRodadaController.text);
              if (kmRodada != null && kmRodada > 0) {
                setStateSB(() {
                  // Atualiza o estado do diálogo
                  // Soma a KM Rodada à KM Atual do Veículo
                  final novaKm = veiculo.kmAtual + kmRodada;
                  kmController.text = novaKm.toString();
                  // Limpa o campo de rodada
                  kmRodadaController.clear();
                });
              }
            }

            return AlertDialog(
              title: const Text('Ajustar KM Atual'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KM Atual Registrada:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // KM Atual (Exibição e Edição Principal)
                    TextFormField(
                      controller: kmController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      inputFormatters: [
                        CurrencyInputFormatterFreeEdit(decimalPrecision: 2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'KM Total Atual (Valor Final)',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // NOVO: KM Rodada (para soma)
                    const Text(
                      'Adicionar KM Rodada (Odômetro Parcial):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: kmRodadaController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            inputFormatters: [
                              CurrencyInputFormatterFreeEdit(
                                decimalPrecision: 2,
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'KM Rodada (N)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // BOTÃO DE ADIÇÃO (SOMA)
                        ElevatedButton.icon(
                          onPressed: somarKms,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Somar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use "Somar" para adicionar a KM Rodada à KM Total.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              actions: [
                // ... (Botões Cancelar e Salvar KM existentes)
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final novaKm = int.tryParse(kmController.text);

                    // ... (Validação e Salvar Lógica existente)
                    if (novaKm == null || novaKm < veiculo.kmAtual) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('KM inválida ou menor que a anterior.'),
                        ),
                      );
                      return;
                    }

                    // Salvar lógica (mantida)
                    final veiculoAtualizado = Veiculo(
                      id: veiculo.id,
                      nome: veiculo.nome,
                      marca: veiculo.marca,
                      ano: veiculo.ano,
                      capacidadeTanqueLitros: veiculo.capacidadeTanqueLitros,
                      mediaManual: veiculo.mediaManual,
                      mediaLongPrazo: veiculo.mediaLongPrazo,
                      kmAtual: novaKm,
                      kmUltimoNivel: veiculo.kmUltimoNivel,
                      litrosNoTanque: veiculo.litrosNoTanque,
                    );

                    context.read<VeiculoBloc>().add(
                      UpdateVeiculo(
                        veiculoAtualizado,
                        veiculo.combustivelIdsAceitos,
                      ),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Salvar KM'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // Diálogo para CALIBRAÇÃO MANUAL DO NÍVEL
  // -----------------------------------------------------------------
  void _showNivelEditDialog(
    BuildContext context,
    Veiculo veiculo,
    double nivelEstimadoLitros,
  ) {
    double nivelPercentual =
        nivelEstimadoLitros / veiculo.capacidadeTanqueLitros;
    if (nivelPercentual > 1.0) nivelPercentual = 1.0;
    if (nivelPercentual < 0.0) nivelPercentual = 0.0;

    double nivelAjustado = nivelPercentual;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            double litrosAjustados =
                nivelAjustado * veiculo.capacidadeTanqueLitros;
            final double sliderWidth =
                MediaQuery.of(context).size.width *
                0.7; // Estimar largura do slider
            return AlertDialog(
              title: const Text('Calibração Manual do Tanque'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ajuste o nível de combustível com base na leitura real do veículo. Isso será usado como novo ponto de partida para a estimativa.',
                    ),
                    const SizedBox(height: 15),

                    Text(
                      'Nível Calibrado: ${litrosAjustados.toStringAsFixed(1)} L (${(nivelAjustado * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: sliderWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Marcadores visuais de 0%, 25%, 50%, 75% e 100%
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 0% (Vermelho)
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.delete,
                              ),
                              // 25%
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 50%
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 75%
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 100%
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.successFromTheme(context),
                              ),
                            ],
                          ),

                          // Slider por cima dos marcadores
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              // O thumb/círculo é mais visível
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0,
                              ),
                              // Cores do trilho para temas claro/escuro
                              activeTrackColor:
                                  AppColors.successFromTheme(context),
                              inactiveTrackColor:
                                  AppColors.sliderInactiveFromTheme(context),
                              // Garante que o slider não tem a linha de ticks por cima
                              tickMarkShape: const RoundSliderTickMarkShape(),
                              showValueIndicator: ShowValueIndicator.onDrag,
                            ),
                            child: Slider(
                              value: nivelAjustado,
                              min: 0.0,
                              max: 1.0,
                              // REMOVIDO: divisions: 4, --> permite ajuste fino

                              // Usaremos a porcentagem como rótulo para refletir o ajuste fino
                              label:
                                  '${(nivelAjustado * 100).toStringAsFixed(0)}%',

                              onChanged: (double value) {
                                setStateSB(() {
                                  nivelAjustado = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vazio', style: TextStyle(fontSize: 12, color: AppColors.greyDark)),
                        Text('1/4', style: TextStyle(fontSize: 12, color: AppColors.greyDark)),
                        Text('1/2', style: TextStyle(fontSize: 12, color: AppColors.greyDark)),
                        Text('3/4', style: TextStyle(fontSize: 12, color: AppColors.greyDark)),
                        Text('Cheio', style: TextStyle(fontSize: 12, color: AppColors.greyDark)),
                      ],
                    ),
                    // ----------------------------------------------------
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final novosLitrosNoTanque =
                        nivelAjustado * veiculo.capacidadeTanqueLitros;

                    final veiculoAtualizado = Veiculo(
                      id: veiculo.id,
                      nome: veiculo.nome,
                      marca: veiculo.marca,
                      ano: veiculo.ano,
                      capacidadeTanqueLitros: veiculo.capacidadeTanqueLitros,

                      mediaManual: veiculo.mediaManual,

                      kmAtual: veiculo.kmAtual,
                      litrosNoTanque: novosLitrosNoTanque,
                      kmUltimoNivel: veiculo.kmAtual,
                    );

                    context.read<VeiculoBloc>().add(
                      UpdateVeiculo(
                        veiculoAtualizado,
                        veiculo.combustivelIdsAceitos,
                      ),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Salvar Calibração'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // Confirmação de Exclusão de Abastecimento
  // -----------------------------------------------------------------
  void _confirmDeleteAbastecimento(
    BuildContext context,
    int abastecimentoId,
    int veiculoId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja deletar este abastecimento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AbastecimentoBloc>().add(
                DeleteAbastecimento(abastecimentoId, veiculoId),
              );
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.delete),
            child: const Text('Deletar', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }
}
