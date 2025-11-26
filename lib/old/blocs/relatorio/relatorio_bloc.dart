// lib/blocs/relatorio/relatorio_bloc.dart

import 'package:car_costs/domain/repositories/abastecimento/abastecimento_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/manutencao_repository.dart';
import '../../models/gasto.dart';
import 'relatorio_event.dart';
import 'relatorio_state.dart';

class RelatorioBloc extends Bloc<RelatorioEvent, RelatorioState> {
  final AbastecimentoRepository _abastecimentoRepository;
  final ManutencaoRepository _manutencaoRepository;

  RelatorioBloc(this._abastecimentoRepository, this._manutencaoRepository)
    : super(RelatorioInitial()) {
    on<GenerateRelatorio>(_onGenerateRelatorio);
  }

  Future<void> _onGenerateRelatorio(
    GenerateRelatorio event,
    Emitter<RelatorioState> emit,
  ) async {
    emit(RelatorioLoading());
    try {
      // 1. Coleta dados de Abastecimento
      final abastecimentos = await _abastecimentoRepository
          .getAbastecimentosByDateRange(
            event.veiculoId,
            event.startDate,
            event.endDate,
          );

      // 2. Coleta dados de Manutenção
      final manutencoes = await _manutencaoRepository.getManutencoesByDateRange(
        event.veiculoId,
        event.startDate,
        event.endDate,
      );

      double totalAbastecimento = 0.0;
      double totalManutencao = 0.0;
      List<Gasto> todosGastos = [];

      // 3. Processa e Agrega Abastecimentos
      for (var a in abastecimentos) {
        totalAbastecimento += a.valorTotal;
        todosGastos.add(
          Gasto(
            id: 'A_${a.id}',
            tipo: 'Abastecimento',
            data: a.data,
            valor: a.valorTotal,
            descricao:
                '${a.tipoCombustivel} - ${a.litrosAbastecidos.toStringAsFixed(2)} L',
          ),
        );
      }

      // 4. Processa e Agrega Manutenções
      for (var m in manutencoes) {
        totalManutencao += m.valor;
        todosGastos.add(
          Gasto(
            id: 'M_${m.id}',
            tipo: 'Manutencao',
            data: m.data,
            valor: m.valor,
            descricao: m.descricao,
          ),
        );
      }

      // 5. Calcula o Total Geral
      final totalGeral = totalAbastecimento + totalManutencao;

      // 6. Ordena a lista de gastos pela data (mais recente primeiro)
      todosGastos.sort((a, b) => b.data.compareTo(a.data));

      // 7. Emite o estado de sucesso
      emit(
        RelatorioLoaded(
          gastos: todosGastos,
          totalAbastecimento: totalAbastecimento,
          totalManutencao: totalManutencao,
          totalGeral: totalGeral,
        ),
      );
    } catch (e) {
      emit(RelatorioError('Falha ao gerar relatório: $e'));
    }
  }
}
