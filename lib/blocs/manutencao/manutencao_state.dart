// lib/blocs/manutencao/manutencao_state.dart

import 'package:equatable/equatable.dart';
import '../../models/manutencao.dart';

// Classe base para todos os estados de Manutenção
abstract class ManutencaoState extends Equatable {
  const ManutencaoState();

  @override
  List<Object> get props => [];
}

class ManutencaoInitial extends ManutencaoState {}

class ManutencaoLoading extends ManutencaoState {}

class ManutencaoLoaded extends ManutencaoState {
  final List<Manutencao> manutencoes;

  const ManutencaoLoaded({this.manutencoes = const []});

  @override
  List<Object> get props => [manutencoes];
}

class ManutencaoError extends ManutencaoState {
  final String message;

  const ManutencaoError(this.message);

  @override
  List<Object> get props => [message];
}
