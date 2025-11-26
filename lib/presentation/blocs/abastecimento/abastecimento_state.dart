// lib/blocs/abastecimento/abastecimento_state.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/abastecimento/abastecimento.dart';

abstract class AbastecimentoState extends Equatable {
  const AbastecimentoState();

  @override
  List<Object> get props => [];
}

class AbastecimentoInitial extends AbastecimentoState {}

class AbastecimentoLoading extends AbastecimentoState {}

class AbastecimentoLoaded extends AbastecimentoState {
  final List<Abastecimento> abastecimentos;

  const AbastecimentoLoaded({this.abastecimentos = const []});

  @override
  List<Object> get props => [abastecimentos];
}

class AbastecimentoError extends AbastecimentoState {
  final String message;

  const AbastecimentoError(this.message);

  @override
  List<Object> get props => [message];
}
