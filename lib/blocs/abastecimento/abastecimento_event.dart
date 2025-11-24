// lib/blocs/abastecimento/abastecimento_event.dart

import 'package:equatable/equatable.dart';
import '../../models/abastecimento.dart';

abstract class AbastecimentoEvent extends Equatable {
  const AbastecimentoEvent();

  @override
  List<Object> get props => [];
}

// Evento para carregar todos os abastecimentos de um veículo específico
class LoadAbastecimentos extends AbastecimentoEvent {
  final int veiculoId;

  const LoadAbastecimentos(this.veiculoId);

  @override
  List<Object> get props => [veiculoId];
}

// Evento para adicionar um novo abastecimento
class AddAbastecimento extends AbastecimentoEvent {
  final Abastecimento abastecimento;

  const AddAbastecimento(this.abastecimento);

  @override
  List<Object> get props => [abastecimento];
}

// Evento para atualizar um abastecimento (se necessário)
class UpdateAbastecimento extends AbastecimentoEvent {
  final Abastecimento abastecimento;

  const UpdateAbastecimento(this.abastecimento);

  @override
  List<Object> get props => [abastecimento];
}

// Evento para deletar um abastecimento
class DeleteAbastecimento extends AbastecimentoEvent {
  final int id;
  final int veiculoId; // Necessário para recarregar a lista

  const DeleteAbastecimento(this.id, this.veiculoId);

  @override
  List<Object> get props => [id, veiculoId];
}
