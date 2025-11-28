// lib/blocs/manutencao/manutencao_event.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/manutencao/manutencao.dart';

// Classe base para todos os eventos de Manutenção
abstract class ManutencaoEvent extends Equatable {
  const ManutencaoEvent();

  @override
  List<Object> get props => [];
}

// Evento para carregar todas as manutenções de um veículo específico
class LoadManutencoes extends ManutencaoEvent {
  final int veiculoId;

  const LoadManutencoes(this.veiculoId);

  @override
  List<Object> get props => [veiculoId];
}

// Evento para adicionar uma nova manutenção
class AddManutencao extends ManutencaoEvent {
  final Manutencao manutencao;

  const AddManutencao(this.manutencao);

  @override
  List<Object> get props => [manutencao];
}

// Evento para deletar uma manutenção
class DeleteManutencao extends ManutencaoEvent {
  final int id;
  final int veiculoId; // Necessário para recarregar a lista

  const DeleteManutencao(this.id, this.veiculoId);

  @override
  List<Object> get props => [id, veiculoId];
}

class UpdateManutencao extends ManutencaoEvent {
  final Manutencao manutencao;

  const UpdateManutencao(this.manutencao);

  @override
  List<Object> get props => [manutencao];
}

// O UpdateManutencao seria similar ao AddManutencao, mas o escopo inicial
// foca no registro e remoção.
