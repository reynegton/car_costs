// lib/blocs/veiculo/veiculo_event.dart

import 'package:equatable/equatable.dart';
import '../../models/veiculo.dart';

// Classe base para todos os eventos de Veículo
abstract class VeiculoEvent extends Equatable {
  const VeiculoEvent();

  @override
  List<Object> get props => [];
}

// Evento para carregar todos os veículos do banco de dados
class LoadVeiculos extends VeiculoEvent {}

// Evento para adicionar um novo veículo
class AddVeiculo extends VeiculoEvent {
  final Veiculo veiculo;
  final List<int> combustivelIds; // NOVO

  const AddVeiculo(this.veiculo, this.combustivelIds); // NOVO

  @override
  List<Object> get props => [veiculo, combustivelIds];
}

// Evento para atualizar um veículo existente
class UpdateVeiculo extends VeiculoEvent {
  final Veiculo veiculo;
  final List<int> combustivelIds; // NOVO

  const UpdateVeiculo(this.veiculo, this.combustivelIds); // NOVO

  @override
  List<Object> get props => [veiculo, combustivelIds];
}

// Evento para deletar um veículo
class DeleteVeiculo extends VeiculoEvent {
  final int id;

  const DeleteVeiculo(this.id);

  @override
  List<Object> get props => [id];
}
