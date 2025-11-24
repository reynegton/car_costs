// lib/screens/veiculo_detail_screen.dart

import 'package:car_costs/core/currency_input_format.dart';
import 'package:car_costs/repositories/configuracao_repository.dart';
import 'package:car_costs/screens/configuracao_dialog.dart';
import 'package:car_costs/screens/relatorio_screen.dart';
import 'package:car_costs/screens/veiculo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/veiculo.dart';
import '../blocs/veiculo/veiculo_bloc.dart';
import '../blocs/veiculo/veiculo_state.dart';
import '../blocs/veiculo/veiculo_event.dart';
import '../blocs/abastecimento/abastecimento_bloc.dart';
import '../blocs/abastecimento/abastecimento_event.dart';
import '../blocs/abastecimento/abastecimento_state.dart';
import 'abastecimento_form_screen.dart';
import 'manutencao_screen.dart';
import 'manutencao_form_screen.dart'; // Necessário para o FAB da aba Manutenções

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

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(currentVeiculo.nome),
                accountEmail: Text(
                  '${currentVeiculo.marca} | KM: ${currentVeiculo.kmAtual}',
                ),
                currentAccountPicture: const Icon(
                  Icons.directions_car,
                  size: 48,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: ListView(
                  children: allVeiculos.map((v) {
                    return ListTile(
                      leading: v.id == currentVeiculo.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.directions_car),
                      title: Text(v.nome),
                      selected: v.id == currentVeiculo.id,
                      onTap: () async {
                        Navigator.of(context).pop(); // Fecha o Drawer

                        if (v.id != currentVeiculo.id) {
                          // 1. SALVAR NOVA PREFERÊNCIA
                          final configRepo = ConfiguracaoRepository();
                          await configRepo.setVeiculoSelecionado(v.id!);

                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    VeiculoDetailScreen(veiculo: v),
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Gerenciar Veículos'),
                onTap: () {
                  Navigator.of(context).pop(); // Fecha o Drawer
                  // Volta para a lista principal de cadastro/seleção
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const VeiculoListScreen(),
                    ),
                    (Route<dynamic> route) =>
                        false, // Remove todas as rotas anteriores
                  );
                },
              ),
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
        // ----------------------------------

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

                // KM ATUAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'KM Atual: ${currentVeiculo.kmAtual} km',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.grey,
                      ),
                      tooltip: 'Ajustar KM/Nível',
                      onPressed: () =>
                          _showKmEditDialog(context, currentVeiculo),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // MÉDIA DE CONSUMO (ULTIMA MÉDIA)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Última Média: ${currentVeiculo.mediaManual.toStringAsFixed(2)} km/l',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // NOVO: AUTONOMIA COM ÚLTIMA MÉDIA
                    Text(
                      'Autonomia: ${autonomiaUltimaMedia.toStringAsFixed(0)} km',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Espaçamento extra
                // MÉDIA DE LONGO PRAZO E BOTÃO DE CONFIG
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.show_chart, color: Colors.purple),
                            const SizedBox(width: 8),
                            Text(
                              'Média Longo Prazo: ${currentVeiculo.mediaLongPrazo.toStringAsFixed(2)} km/l',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            size: 20,
                            color: Colors.purple,
                          ),
                          tooltip: 'Configurar Média Longo Prazo (N)',
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (ctx) => const ConfiguracaoDialog(),
                            );
                            if (context.mounted) {
                              context.read<AbastecimentoBloc>().add(
                                LoadAbastecimentos(currentVeiculo.id!),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    // NOVO: AUTONOMIA COM MÉDIA LONGO PRAZO
                    Text(
                      'Autonomia: ${autonomiaLongoPrazo.toStringAsFixed(0)} km',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.purple,
                      ),
                    ),

                    // BOTÃO DE CONFIGURAÇÃO (existente)
                  ],
                ),

                // MARCADOR DE COMBUSTÍVEL ESTIMADO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nível Estimado: ${(nivelPercentual * 100).toStringAsFixed(0)}% (${nivelEstimadoLitros.toStringAsFixed(1)} L)',
                      style: const TextStyle(fontSize: 16),
                    ),
                    // BOTÃO DE CALIBRAÇÃO
                    IconButton(
                      icon: const Icon(
                        Icons.tune,
                        size: 20,
                        color: Colors.orange,
                      ),
                      tooltip: 'Calibrar Nível Manualmente',
                      onPressed: () => _showNivelEditDialog(
                        context,
                        currentVeiculo,
                        nivelEstimadoLitros,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // ----------------------------------------------------
                // NOVO: MEDIDOR DE PROGRESSO COM MARCADORES VISUAIS
                // ----------------------------------------------------
                SizedBox(
                  height: 20, // Altura para o indicador e os marcadores
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. O PRÓPRIO INDICADOR DE PROGRESSO
                      LinearProgressIndicator(
                        value: nivelPercentual,
                        backgroundColor: Colors.grey[300],
                        color: nivelPercentual > 0.2 ? Colors.green : Colors.red,
                        minHeight: 10,
                      ),

                      // 2. LINHA DE MARCADORES (Ticks)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Calcula a largura total do indicador para posicionar os marcadores
                          final totalWidth = constraints.maxWidth;
                          
                          // Cria os marcadores de 1/4, 1/2, e 3/4
                          return Row(
                            children: [
                              // Marcador de 1/4 (25% da largura)
                              SizedBox(width: totalWidth * 0.25 - 1.5), 
                              Container(width: 3, height: 10, color: Color.fromRGBO(0, 0, 0, 0.5)),
                              
                              // Marcador de 1/2 (25% restante)
                              SizedBox(width: totalWidth * 0.25 - 3),
                              Container(width: 3, height: 10, color: Color.fromRGBO(0, 0, 0, 0.5)),
                              
                              // Marcador de 3/4 (25% restante)
                              SizedBox(width: totalWidth * 0.25 - 3),
                              Container(width: 3, height: 10, color: Color.fromRGBO(0, 0, 0, 0.5)),
                              
                              // O último SizedBox (25% restante) leva ao final (100%)
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Rótulos na Base (Opcional, mas altamente recomendado para clareza)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 0), // Posição 0%
                    Text('1/4', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('1/2', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('3/4', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
          if (state.abastecimentos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Nenhum abastecimento registrado.'),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.abastecimentos.length,
            itemBuilder: (context, index) {
              final a = state.abastecimentos[index];
              final date = DateFormat(
                'dd/MM/yy',
              ).format(DateTime.parse(a.data));

              return ListTile(
                leading: Icon(
                  a.tanqueCheio ? Icons.local_gas_station : Icons.local_parking,
                  color: a.tanqueCheio ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  '$date - ${a.tipoCombustivel} (${a.litrosAbastecidos.toStringAsFixed(2)} L)',
                ),
                subtitle: Text(
                  'KM ${a.kmAtual} | Total: R\$ ${a.valorTotal.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Exibição da Média (Existente)
                    Text(
                      a.mediaCalculada != null
                          ? 'Média: ${a.mediaCalculada!.toStringAsFixed(2)} km/l'
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: a.mediaCalculada != null
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // BOTÃO DE REMOÇÃO (NOVO)
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => _confirmDeleteAbastecimento(
                        context,
                        a.id!,
                        veiculoId,
                      ),
                    ),
                  ],
                ),
                // REMOVIDO: onLongPress: () => _confirmDeleteAbastecimento(context, a.id!, veiculoId),
              );
            },
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
                          // 1. Linha de Marcadores
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 0%
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.red,
                              ),
                              // 25%
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 50%
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 75%
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 100%
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.green,
                              ),
                            ],
                          ),

                          // 2. O Slider, SEM DIVISÕES, por cima
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              // O thumb/círculo é mais visível
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0,
                              ),
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
                        Text('Vazio', style: TextStyle(fontSize: 12)),
                        Text('1/4', style: TextStyle(fontSize: 12)),
                        Text('1/2', style: TextStyle(fontSize: 12)),
                        Text('3/4', style: TextStyle(fontSize: 12)),
                        Text('Cheio', style: TextStyle(fontSize: 12)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
