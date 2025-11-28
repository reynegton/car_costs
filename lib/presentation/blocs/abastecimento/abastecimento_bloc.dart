// lib/blocs/abastecimento/abastecimento_bloc.dart

import 'package:car_costs/domain/repositories/abastecimento/abastecimento_repository.dart';
import 'package:car_costs/data/models/veiculo/veiculo.dart';
import 'package:car_costs/domain/repositories/configuracao/configuracao_repository.dart';
import 'package:car_costs/domain/repositories/veiculo/veiculo_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'abastecimento_event.dart';
import 'abastecimento_state.dart';

class AbastecimentoBloc extends Bloc<AbastecimentoEvent, AbastecimentoState> {
  final AbastecimentoRepository _abastecimentoRepository;
  final VeiculoRepository _veiculoRepository; // Dependência adicional
  final ConfiguracaoRepository _configuracaoRepository;

  AbastecimentoBloc(
    this._abastecimentoRepository,
    this._veiculoRepository,
    this._configuracaoRepository,
  ) : super(AbastecimentoInitial()) {
    on<LoadAbastecimentos>(_onLoadAbastecimentos);
    on<AddAbastecimento>(_onAddAbastecimento);
    on<DeleteAbastecimento>(_onDeleteAbastecimento);
    // on<UpdateAbastecimento>(_onUpdateAbastecimento); // Implementar se necessário
  }

  // -----------------------------------------------------------------
  // Handler para LoadAbastecimentos
  // -----------------------------------------------------------------
  Future<void> _onLoadAbastecimentos(
    LoadAbastecimentos event,
    Emitter<AbastecimentoState> emit,
  ) async {
    emit(AbastecimentoLoading());
    try {
      final abastecimentos = await _abastecimentoRepository
          .getAbastecimentosByVeiculo(event.veiculoId);
      emit(AbastecimentoLoaded(abastecimentos: abastecimentos));
    } catch (e) {
      emit(AbastecimentoError('Falha ao carregar abastecimentos: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para AddAbastecimento (A mais importante!)
  // -----------------------------------------------------------------
  Future<void> _onAddAbastecimento(
    AddAbastecimento event,
    Emitter<AbastecimentoState> emit,
  ) async {
    try {
      // 1. Inserir o abastecimento
      await _abastecimentoRepository.insertAbastecimento(event.abastecimento);

      // 2. Atualizar a KM atual do Veículo
      var veiculo = await _veiculoRepository.getVeiculoById(
        event.abastecimento.veiculoId,
      );

      // Validação: Garante que o veículo foi encontrado
      if (veiculo == null) {
        emit(
          AbastecimentoError('Veículo não encontrado para atualização de KM.'),
        );
        return;
      }

      // Se a KM do novo abastecimento for maior que a registrada no veículo
      if (veiculo.kmAtual < event.abastecimento.kmAtual) {
        veiculo.kmAtual = event.abastecimento.kmAtual;

        // --- LÓGICA DE ATUALIZAÇÃO DO NÍVEL DO TANQUE ---
        if (event.abastecimento.tanqueCheio) {
          // Se for tanque cheio, o nível atual é a capacidade máxima
          veiculo.litrosNoTanque = veiculo.capacidadeTanqueLitros;
        } else {
          // Caso contrário, adiciona o que foi abastecido ao que já existia
          veiculo.litrosNoTanque += event.abastecimento.litrosAbastecidos;
        }

        // Atualiza a KM de referência do último nível registrado
        veiculo.kmUltimoNivel = event.abastecimento.kmAtual;
        // --------------------------------------------------

        // 3. (OPCIONALMENTE) Calcular e atualizar a Média
        veiculo = await _calculateAndUpdateMedia(veiculo);

        // SALVA AS MUDANÇAS (KM e Média) NO BANCO
        await _veiculoRepository.updateVeiculo(
          veiculo,
          veiculo.combustivelIdsAceitos,
        );
      }

      await _configuracaoRepository.setEncheuTanqueUltimoAbastecimento(
        event.abastecimento.tanqueCheio, // Usa o valor que veio do formulário
      );

      // 4. Recarregar a lista de abastecimentos
      add(LoadAbastecimentos(event.abastecimento.veiculoId));
    } catch (e) {
      emit(AbastecimentoError('Falha ao adicionar abastecimento: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Handler para DeleteAbastecimento
  // -----------------------------------------------------------------
  Future<void> _onDeleteAbastecimento(
    DeleteAbastecimento event,
    Emitter<AbastecimentoState> emit,
  ) async {
    try {
      await _abastecimentoRepository.deleteAbastecimento(event.id);

      // *** NOVO: FORÇAR O RECALCULO DE MÉDIAS ***
      // Buscamos o veículo atualizado para recalcular e salvar
      var veiculo = await _veiculoRepository.getVeiculoById(event.veiculoId);

      if (veiculo != null) {
        // A função recalcula e atualiza as médias no objeto veiculo e no banco
        veiculo = await _calculateAndUpdateMedia(veiculo);
        await _veiculoRepository.updateVeiculo(
          veiculo,
          veiculo.combustivelIdsAceitos,
        );
      }
      // ********************************************

      // Recarrega a lista
      add(LoadAbastecimentos(event.veiculoId));
    } catch (e) {
      emit(AbastecimentoError('Falha ao deletar abastecimento: $e'));
    }
  }

  // -----------------------------------------------------------------
  // Lógica Auxiliar de Cálculo de Média (Conforme sua regra!)
  // -----------------------------------------------------------------
  Future<Veiculo> _calculateAndUpdateMedia(Veiculo v) async {
    final allAbastecimentos = await _abastecimentoRepository
        .getAbastecimentosByVeiculo(v.id!);

    // Filtramos apenas os abastecimentos de tanque cheio, ordenados por KM (decrescente)
    final fullTankAbastecimentos = allAbastecimentos
        .where((a) => a.tanqueCheio)
        .toList();

    if (fullTankAbastecimentos.length < 2) {
      // Precisamos de pelo menos dois abastecimentos de tanque cheio para o cálculo
      return v;
    }

    // O abastecimento mais recente de tanque cheio (Índice 0)
    final ultimoCheio = fullTankAbastecimentos[0];
    // O abastecimento anterior de tanque cheio (Índice 1)
    final penultimoCheio = fullTankAbastecimentos[1];

    // Obter todos os abastecimentos ENTRE o último e o penúltimo tanque cheio.
    // Usamos a KM como base para a ordem
    final abastecimentosEntre = allAbastecimentos
        .where(
          (a) =>
              a.kmAtual > penultimoCheio.kmAtual &&
              a.kmAtual <= ultimoCheio.kmAtual,
        )
        .toList();

    // Soma da Litragem e Distância
    double totalLitros = 0.0;
    // Pela sua regra, a KM rodada é a diferença entre a KM do último cheio e do penúltimo
    int kmRodada = ultimoCheio.kmAtual - penultimoCheio.kmAtual;

    // Somamos a litragem de TODOS os abastecimentos ENTRE (incluindo o último, mas não o penúltimo)
    for (var a in abastecimentosEntre) {
      totalLitros += a.litrosAbastecidos;
    }

    if (kmRodada > 0 && totalLitros > 0) {
      // Média = KM Rodada / Litros
      double media = kmRodada / totalLitros;

      // *** CORREÇÃO: ATUALIZAR mediaManual do Veículo ***
      v.mediaManual = media;

      // Atualiza o campo mediaCalculada do último abastecimento de tanque cheio no BD
      ultimoCheio.mediaCalculada = media;
      await _abastecimentoRepository.updateAbastecimento(ultimoCheio);
      fullTankAbastecimentos.add(ultimoCheio); // Atualiza a lista local também
    }

    // ------------------------------------------------------
    // NOVO: Cálculo da Média de Longo Prazo
    // ------------------------------------------------------
    final config = await _configuracaoRepository.getConfiguracao();
    final n = config.mediaApuracaoN;

    final mediasRelevantes = fullTankAbastecimentos
        .where((a) => a.mediaCalculada != null)
        .map((a) => a.mediaCalculada!)
        .take(n) // Pega apenas as N mais recentes
        .toList();

    double mediaLongPrazo = 0.0;
    if (mediasRelevantes.isNotEmpty) {
      final somaMedias = mediasRelevantes.reduce((a, b) => a + b);
      mediaLongPrazo = somaMedias / mediasRelevantes.length;
    }

    v.mediaLongPrazo = mediaLongPrazo;

    return v;
  }
}
