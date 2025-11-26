// lib/blocs/relatorio/relatorio_event.dart

import 'package:equatable/equatable.dart';

abstract class RelatorioEvent extends Equatable {
  const RelatorioEvent();

  @override
  List<Object> get props => [];
}

class GenerateRelatorio extends RelatorioEvent {
  final int veiculoId;
  final String startDate;
  final String endDate;

  const GenerateRelatorio({
    required this.veiculoId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [veiculoId, startDate, endDate];
}
