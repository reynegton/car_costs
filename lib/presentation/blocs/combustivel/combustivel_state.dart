// lib/blocs/combustivel/combustivel_state.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/combustivel/combustivel.dart';

abstract class CombustivelState extends Equatable {
  const CombustivelState();
  @override
  List<Object> get props => [];
}

class CombustivelInitial extends CombustivelState {}

class CombustivelLoading extends CombustivelState {}

class CombustivelLoaded extends CombustivelState {
  final List<Combustivel> combustiveisAceitos;
  final int? ultimoCombustivelId; // ID do último usado

  const CombustivelLoaded({
    this.combustiveisAceitos = const [],
    this.ultimoCombustivelId,
  });

  // NOVO: Implementação do método copyWith
  CombustivelLoaded copyWith({
    List<Combustivel>? combustiveisAceitos,
    int? ultimoCombustivelId,
  }) {
    return CombustivelLoaded(
      combustiveisAceitos: combustiveisAceitos ?? this.combustiveisAceitos,
      ultimoCombustivelId: ultimoCombustivelId ?? this.ultimoCombustivelId,
    );
  }

  @override
  List<Object> get props => [combustiveisAceitos, ultimoCombustivelId ?? 0];
}

class CombustivelError extends CombustivelState {
  final String message;
  const CombustivelError(this.message);
  @override
  List<Object> get props => [message];
}
