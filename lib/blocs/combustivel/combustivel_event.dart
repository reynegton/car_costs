// lib/blocs/combustivel/combustivel_event.dart

import 'package:equatable/equatable.dart';

abstract class CombustivelEvent extends Equatable {
  const CombustivelEvent();
  @override
  List<Object> get props => [];
}

// Evento para carregar todos os combustíveis aceitos por um veículo E o último usado.
class LoadCombustiveisData extends CombustivelEvent {
  final int veiculoId;

  const LoadCombustiveisData(this.veiculoId);
  @override
  List<Object> get props => [veiculoId];
}

// Evento para salvar o último combustível usado
class SetUltimoCombustivel extends CombustivelEvent {
  final int combustivelId;

  const SetUltimoCombustivel(this.combustivelId);
  @override
  List<Object> get props => [combustivelId];
}
