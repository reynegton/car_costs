// lib/blocs/relatorio/relatorio_state.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/relatorio/gasto.dart';

abstract class RelatorioState extends Equatable {
  const RelatorioState();

  @override
  List<Object> get props => [];
}

class RelatorioInitial extends RelatorioState {}

class RelatorioLoading extends RelatorioState {}

class RelatorioLoaded extends RelatorioState {
  final List<Gasto> gastos;
  final double totalAbastecimento;
  final double totalManutencao;
  final double totalGeral;

  const RelatorioLoaded({
    required this.gastos,
    required this.totalAbastecimento,
    required this.totalManutencao,
    required this.totalGeral,
  });

  @override
  List<Object> get props => [
    gastos,
    totalAbastecimento,
    totalManutencao,
    totalGeral,
  ];
}

class RelatorioError extends RelatorioState {
  final String message;

  const RelatorioError(this.message);

  @override
  List<Object> get props => [message];
}
