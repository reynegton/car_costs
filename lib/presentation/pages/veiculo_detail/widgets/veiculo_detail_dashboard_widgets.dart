import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_costs/core/app_colors.dart';
import 'package:car_costs/presentation/pages/configuracao/configuracao_dialog.dart';

import '../../../../data/models/veiculo/veiculo.dart';
import '../../../blocs/abastecimento/abastecimento_bloc.dart';
import '../../../blocs/abastecimento/abastecimento_event.dart';

Widget buildKmAtualRow(BuildContext context, Veiculo currentVeiculo, void Function() onEdit) {
  // KM ATUAL
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(Icons.speed, color: AppColors.infoFromTheme(context)),
          const SizedBox(width: 8),
          Text(
            'KM Atual: ${currentVeiculo.kmAtual} km',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      IconButton(
        icon: const Icon(
          Icons.edit,
          size: 20,
          color: AppColors.greyDark,
        ),
        tooltip: 'Ajustar KM/Nível',
        onPressed: onEdit,
      ),
    ],
  );
}

Widget buildMediaSection(
  BuildContext context,
  Veiculo currentVeiculo,
  double autonomiaUltimaMedia,
) {
  // MÉDIA DE CONSUMO (ULTIMA MÉDIA)
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.trending_up, color: AppColors.successFromTheme(context)),
          const SizedBox(width: 8),
          Text(
            'Última Média: ${currentVeiculo.mediaManual.toStringAsFixed(2)} km/l',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      // NOVO: AUTONOMIA COM ÚLTIMA MÉDIA
      Text(
        'Autonomia: ${autonomiaUltimaMedia.toStringAsFixed(0)} km',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.successFromTheme(context),
        ),
      ),
    ],
  );
}

Widget buildMediaLongoPrazoSection(
  BuildContext context,
  Veiculo currentVeiculo,
  double autonomiaLongoPrazo,
) {
  // MÉDIA DE LONGO PRAZO E BOTÃO DE CONFIG
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart,
                  color: AppColors.purpleFromTheme(context)),
              const SizedBox(width: 8),
              Text(
                'Média Longo Prazo: ${currentVeiculo.mediaLongPrazo.toStringAsFixed(2)} km/l',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 20,
              color: AppColors.purpleFromTheme(context),
            ),
            tooltip: 'Configurar Média Longo Prazo (N)',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (ctx) => const ConfiguracaoDialog(),
              );
              if (context.mounted) {
                context.read<AbastecimentoBloc>().add(
                      LoadAbastecimentos(currentVeiculo.id!),
                    );
              }
            },
          ),
        ],
      ),
      // NOVO: AUTONOMIA COM MÉDIA LONGO PRAZO
      Text(
        'Autonomia: ${autonomiaLongoPrazo.toStringAsFixed(0)} km',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.purpleFromTheme(context),
        ),
      ),

      // BOTÃO DE CONFIGURAÇÃO (existente)
    ],
  );
}

Widget buildNivelSection(
  BuildContext context,
  Veiculo currentVeiculo,
  double nivelEstimadoLitros,
  double nivelPercentual,
  void Function() onCalibrar,
) {
  // MARCADOR DE COMBUSTÍVEL ESTIMADO
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Nível Estimado: ${(nivelPercentual * 100).toStringAsFixed(0)}% (${nivelEstimadoLitros.toStringAsFixed(1)} L)',
        style: const TextStyle(fontSize: 16),
      ),
      // BOTÃO DE CALIBRAÇÃO
      IconButton(
        icon: Icon(
          Icons.tune,
          size: 20,
          color: AppColors.warningFromTheme(context),
        ),
        tooltip: 'Calibrar Nível Manualmente',
        onPressed: onCalibrar,
      ),
    ],
  );
}

Widget buildNivelProgressBar(BuildContext context, double nivelPercentual) {
  // ----------------------------------------------------
  // NOVO: MEDIDOR DE PROGRESSO COM MARCADORES VISUAIS
  // ----------------------------------------------------
  return SizedBox(
    height: 20, // Altura para o indicador e os marcadores
    child: Stack(
      alignment: Alignment.center,
      children: [
        // 1. O PRÓPRIO INDICADOR DE PROGRESSO
        LinearProgressIndicator(
          value: nivelPercentual,
          backgroundColor: AppColors.progressBackground,
          color:
              nivelPercentual > 0.2 ? AppColors.successFromTheme(context) : AppColors.delete,
          minHeight: 10,
        ),

        // 2. LINHA DE MARCADORES (Ticks)
        LayoutBuilder(
          builder: (context, constraints) {
            // Calcula a largura total do indicador para posicionar os marcadores
            final totalWidth = constraints.maxWidth;

            // Cria os marcadores de 1/4, 1/2, e 3/4
            return Row(
              children: [
                // Marcador de 1/4 (25% da largura)
                SizedBox(width: totalWidth * 0.25 - 1.5),
                Container(width: 3, height: 10, color: AppColors.fuelGaugeTick),

                // Marcador de 1/2 (25% restante)
                SizedBox(width: totalWidth * 0.25 - 3),
                Container(width: 3, height: 10, color: AppColors.fuelGaugeTick),

                // Marcador de 3/4 (25% restante)
                SizedBox(width: totalWidth * 0.25 - 3),
                Container(width: 3, height: 10, color: AppColors.fuelGaugeTick),

                // O último SizedBox (25% restante) leva ao final (100%)
              ],
            );
          },
        ),
      ],
    ),
  );
}
