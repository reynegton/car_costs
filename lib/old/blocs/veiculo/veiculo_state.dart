// lib/blocs/veiculo/veiculo_state.dart

import 'package:equatable/equatable.dart';
import '../../models/veiculo.dart';

// Classe base para todos os estados de Veículo
abstract class VeiculoState extends Equatable {
  const VeiculoState();

  @override
  List<Object> get props => [];
}

// 1. Estado Inicial - Nenhuma operação foi feita ainda
class VeiculoInitial extends VeiculoState {}

// 2. Estado de Carregamento - Indica que uma operação está em andamento (ex: buscando no BD)
class VeiculoLoading extends VeiculoState {}

// 3. Estado de Sucesso - Contém a lista atualizada de veículos
class VeiculoLoaded extends VeiculoState {
  final List<Veiculo> veiculos;

  const VeiculoLoaded({this.veiculos = const []});

  // Permite criar uma cópia com novos dados, mantendo o estado anterior
  VeiculoLoaded copyWith({List<Veiculo>? veiculos}) {
    return VeiculoLoaded(veiculos: veiculos ?? this.veiculos);
  }

  @override
  List<Object> get props => [veiculos];
}

// 4. Estado de Erro - Ocorreu um problema na operação
class VeiculoError extends VeiculoState {
  final String message;

  const VeiculoError(this.message);

  @override
  List<Object> get props => [message];
}
