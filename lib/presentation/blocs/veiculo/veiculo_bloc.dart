// lib/blocs/veiculo/veiculo_bloc.dart

import 'package:car_costs/domain/repositories/veiculo/veiculo_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'veiculo_event.dart';
import 'veiculo_state.dart';

class VeiculoBloc extends Bloc<VeiculoEvent, VeiculoState> {
  final VeiculoRepository _repository;
  

  // O BLoC começa no estado inicial
  VeiculoBloc(this._repository) : super(VeiculoInitial()) {
    // Registra os 'Handlers' (funções que tratam cada Evento)
    on<LoadVeiculos>(_onLoadVeiculos);
    on<AddVeiculo>(_onAddVeiculo);
    on<UpdateVeiculo>(_onUpdateVeiculo);
    on<DeleteVeiculo>(_onDeleteVeiculo);
  }

  // -----------------------------------------------------------------
  // Handler para LoadVeiculos (Carregar a lista)
  // -----------------------------------------------------------------
  Future<void> _onLoadVeiculos(
    LoadVeiculos event,
    Emitter<VeiculoState> emit,
  ) async {
    emit(VeiculoLoading());
    try {
      final veiculos = await _repository.getVeiculos();

      // *** CORREÇÃO: Preencher o campo combustivelIdsAceitos ***
      for (var veiculo in veiculos) {
        if (veiculo.id != null) {
          final ids = await _repository.getCombustivelIdsByVeiculo(
            veiculo.id!,
          );
          veiculo.combustivelIdsAceitos = ids;
        }
      }
      // *******************************************************

      emit(VeiculoLoaded(veiculos: veiculos));
    } catch (e) {
      emit(VeiculoError('Falha ao carregar veículos: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para AddVeiculo (Adicionar um novo)
  // -----------------------------------------------------------------
  Future<void> _onAddVeiculo(
    AddVeiculo event,
    Emitter<VeiculoState> emit,
  ) async {
    try {
      // O Repositório agora requer a lista de IDs
      await _repository.insertVeiculo(event.veiculo, event.combustivelIds);

      add(LoadVeiculos());
    } catch (e) {
      emit(VeiculoError('Falha ao adicionar veículo: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para UpdateVeiculo (Atualizar)
  // -----------------------------------------------------------------
  Future<void> _onUpdateVeiculo(
    UpdateVeiculo event,
    Emitter<VeiculoState> emit,
  ) async {
    try {
      // O Repositório agora requer a lista de IDs
      await _repository.updateVeiculo(event.veiculo, event.combustivelIds);

      add(LoadVeiculos());
    } catch (e) {
      emit(VeiculoError('Falha ao atualizar veículo: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para DeleteVeiculo (Deletar)
  // -----------------------------------------------------------------
  Future<void> _onDeleteVeiculo(
    DeleteVeiculo event,
    Emitter<VeiculoState> emit,
  ) async {
    try {
      await _repository.deleteVeiculo(event.id);
      // Recarrega a lista
      add(LoadVeiculos());
    } catch (e) {
      emit(VeiculoError('Falha ao deletar veículo: $e'));
    }
  }
}
