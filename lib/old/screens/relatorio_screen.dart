// lib/screens/relatorio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/veiculo.dart';
import '../blocs/relatorio/relatorio_bloc.dart';
import '../blocs/relatorio/relatorio_event.dart';
import '../blocs/relatorio/relatorio_state.dart';

class RelatorioScreen extends StatefulWidget {
  final Veiculo veiculo;

  const RelatorioScreen({super.key, required this.veiculo});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Formatador de Data e Moeda
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayDateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    // Gera o relatório inicial (últimos 30 dias)
    _generateReport();
  }

  void _generateReport() {
    // Dispara o evento de geração de relatório
    context.read<RelatorioBloc>().add(
      GenerateRelatorio(
        veiculoId: widget.veiculo.id!,
        startDate: _dateFormat.format(_startDate),
        endDate: _dateFormat.format(_endDate),
      ),
    );
  }

  // Função para mudar o intervalo para presets (Semanal, Mensal, etc.)
  void _setPresetDateRange(String preset) {
    setState(() {
      _endDate = DateTime.now();
      switch (preset) {
        case 'Semanal':
          _startDate = _endDate.subtract(const Duration(days: 7));
          break;
        case 'Mensal':
          _startDate = _endDate.subtract(const Duration(days: 30));
          break;
        case 'Semestral':
          _startDate = _endDate.subtract(const Duration(days: 180));
          break;
        case 'Anual':
          _startDate = _endDate.subtract(const Duration(days: 365));
          break;
      }
    });
    _generateReport();
  }

  // Diálogo para seleção de data customizada
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _generateReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Gastos: ${widget.veiculo.nome}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterControls(context),
          const Divider(),
          Expanded(
            child: BlocBuilder<RelatorioBloc, RelatorioState>(
              builder: (context, state) {
                if (state is RelatorioLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RelatorioError) {
                  return Center(child: Text('Erro: ${state.message}'));
                }
                if (state is RelatorioLoaded) {
                  return _buildReportContent(context, state);
                }
                return const Center(
                  child: Text('Selecione um período para gerar o relatório.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // UI: Controles de Filtro
  // ----------------------------------------------------
  Widget _buildFilterControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Filtros de Data Rápida
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Semanal', 'Mensal', 'Semestral', 'Anual'].map((
                preset,
              ) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Text(preset),
                    onPressed: () => _setPresetDateRange(preset),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Seleção de Data Customizada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('Início: ${_displayDateFormat.format(_startDate)}'),
                onPressed: () => _selectDate(context, true),
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('Fim: ${_displayDateFormat.format(_endDate)}'),
                onPressed: () => _selectDate(context, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // UI: Conteúdo do Relatório
  // ----------------------------------------------------
  Widget _buildReportContent(BuildContext context, RelatorioLoaded state) {
    return Column(
      children: [
        // Resumo de Totais
        Card(
          color: Colors.blue.shade50,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTotalRow(
                  'Total Abastecimento:',
                  state.totalAbastecimento,
                  Colors.blue,
                ),
                _buildTotalRow(
                  'Total Manutenção:',
                  state.totalManutencao,
                  Colors.indigo,
                ),
                const Divider(thickness: 2),
                _buildTotalRow(
                  'TOTAL GERAL:',
                  state.totalGeral,
                  Colors.red,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),

        // Lista Detalhada
        Expanded(
          child: ListView.builder(
            itemCount: state.gastos.length + 1, // +1 para o cabeçalho
            itemBuilder: (context, index) {
              if (index == 0) {
                return const ListTile(
                  title: Text(
                    'Detalhes dos Gastos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    'Valor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }
              final gasto = state.gastos[index - 1];
              return ListTile(
                leading: Icon(
                  gasto.tipo == 'Abastecimento'
                      ? Icons.local_gas_station
                      : Icons.build,
                  color: gasto.tipo == 'Abastecimento'
                      ? Colors.blue
                      : Colors.indigo,
                ),
                title: Text(gasto.descricao),
                subtitle: Text(
                  '${gasto.tipo} - ${_displayDateFormat.format(DateTime.parse(gasto.data))}',
                ),
                trailing: Text(
                  _currencyFormat.format(gasto.valor),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: gasto.tipo == 'Abastecimento'
                        ? Colors.blue
                        : Colors.indigo,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // UI: Linha de Totais
  // ----------------------------------------------------
  Widget _buildTotalRow(
    String label,
    double value,
    Color color, {
    bool isBold = false,
  }) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: isBold ? Colors.black : color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(_currencyFormat.format(value), style: style),
        ],
      ),
    );
  }
}
