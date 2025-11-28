// lib/blocs/manutencao/manutencao_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/manutencao/manutencao_repository_impl.dart';
import 'manutencao_event.dart';
import 'manutencao_state.dart';

class ManutencaoBloc extends Bloc<ManutencaoEvent, ManutencaoState> {
  final ManutencaoRepositoryImpl _repository;

  ManutencaoBloc(this._repository) : super(ManutencaoInitial()) {
    on<LoadManutencoes>(_onLoadManutencoes);
    on<AddManutencao>(_onAddManutencao);
    on<DeleteManutencao>(_onDeleteManutencao);
    on<UpdateManutencao>(_onUpdateManutencao);
  }

  // -----------------------------------------------------------------
  // Handler para LoadManutencoes (Carregar a lista)
  // -----------------------------------------------------------------
  Future<void> _onLoadManutencoes(
    LoadManutencoes event,
    Emitter<ManutencaoState> emit,
  ) async {
    emit(ManutencaoLoading());
    try {
      final manutencoes = await _repository.getManutencoesByVeiculo(
        event.veiculoId,
      );
      emit(ManutencaoLoaded(manutencoes: manutencoes));
    } catch (e) {
      emit(ManutencaoError('Falha ao carregar manutenções: $e'));
    }
  }
  // -----------------------------------------------------------------
  // Handler para UpdateManutencao (Atualizar)
  // -----------------------------------------------------------------
  Future<void> _onUpdateManutencao(
    UpdateManutencao event,
    Emitter<ManutencaoState> emit,
  ) async {
    try {
      await _repository.updateManutencao(event.manutencao);
      
      // Recarrega a lista para refletir a mudança
      add(LoadManutencoes(event.manutencao.veiculoId));
    } catch (e) {
      emit(ManutencaoError('Falha ao atualizar manutenção: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para AddManutencao (Adicionar uma nova)
  // -----------------------------------------------------------------
  Future<void> _onAddManutencao(
    AddManutencao event,
    Emitter<ManutencaoState> emit,
  ) async {
    try {
      await _repository.insertManutencao(event.manutencao);

      // Recarrega a lista para refletir a mudança
      add(LoadManutencoes(event.manutencao.veiculoId));
    } catch (e) {
      emit(ManutencaoError('Falha ao adicionar manutenção: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para DeleteManutencao (Deletar)
  // -----------------------------------------------------------------
  Future<void> _onDeleteManutencao(
    DeleteManutencao event,
    Emitter<ManutencaoState> emit,
  ) async {
    try {
      await _repository.deleteManutencao(event.id);

      // Recarrega a lista
      add(LoadManutencoes(event.veiculoId));
    } catch (e) {
      emit(ManutencaoError('Falha ao deletar manutenção: $e'));
    }
  }
}
