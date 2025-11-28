// lib/blocs/combustivel/combustivel_bloc.dart

import 'package:car_costs/domain/repositories/combustivel/combustivel_repository.dart';
import 'package:car_costs/domain/repositories/configuracao/configuracao_repository.dart';
import 'package:car_costs/domain/repositories/veiculo/veiculo_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'combustivel_event.dart';
import 'combustivel_state.dart';

class CombustivelBloc extends Bloc<CombustivelEvent, CombustivelState> {
  final CombustivelRepository _combustivelRepo;
  final VeiculoRepository _veiculoRepo;
  final ConfiguracaoRepository _configRepo;

  CombustivelBloc(this._combustivelRepo, this._veiculoRepo, this._configRepo)
    : super(CombustivelInitial()) {
    on<LoadCombustiveisData>(_onLoadCombustiveisData);
    on<SetUltimoCombustivel>(_onSetUltimoCombustivel);
  }

  // Handler para carregar a lista filtrada e o último ID usado
  Future<void> _onLoadCombustiveisData(
    LoadCombustiveisData event,
    Emitter<CombustivelState> emit,
  ) async {
    emit(CombustivelLoading());
    try {
      // 1. Obter IDs aceitos pelo veículo
      final acceptedIds = await _veiculoRepo.getCombustivelIdsByVeiculo(
        event.veiculoId,
      );

      // 2. Obter todos os combustíveis e filtrar
      final all = await _combustivelRepo.getAllCombustiveis();
      final acceptedObjects = all
          .where((c) => acceptedIds.contains(c.id))
          .toList();

      // 3. Obter o último ID salvo
      final ultimoId = await _configRepo.getUltimoCombustivelId();

      emit(
        CombustivelLoaded(
          combustiveisAceitos: acceptedObjects,
          ultimoCombustivelId: ultimoId,
        ),
      );
    } catch (e) {
      emit(CombustivelError('Falha ao carregar dados de combustível: $e'));
    }
  }

  // Handler para salvar a preferência de último combustível
  Future<void> _onSetUltimoCombustivel(
    SetUltimoCombustivel event,
    Emitter<CombustivelState> emit,
  ) async {
    try {
      await _configRepo.setUltimoCombustivelId(event.combustivelId);

      // Se o estado já estava carregado, atualiza apenas a preferência
      if (state is CombustivelLoaded) {
        final loadedState = state as CombustivelLoaded;
        emit(loadedState.copyWith(ultimoCombustivelId: event.combustivelId));
      }
    } catch (_) {}
  }
}
