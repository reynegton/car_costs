import 'package:flutter/material.dart';

import 'package:car_costs/core/app_colors.dart';
import 'package:intl/intl.dart';

import '../../../blocs/abastecimento/abastecimento_state.dart';

Widget buildAbastecimentoLoadedBody(
  BuildContext context,
  AbastecimentoLoaded state,
  int veiculoId,
  void Function(int abastecimentoId, int veiculoId) onDelete,
) {
  if (state.abastecimentos.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Nenhum abastecimento registrado.'),
      ),
    );
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: state.abastecimentos.length,
    itemBuilder: (context, index) {
      final a = state.abastecimentos[index];
      return buildAbastecimentoTile(context, a, veiculoId, onDelete);
    },
  );
}

Widget buildAbastecimentoTile(
  BuildContext context,
  dynamic a,
  int veiculoId,
  void Function(int abastecimentoId, int veiculoId) onDelete,
) {
  final date = DateFormat(
    'dd/MM/yy',
  ).format(DateTime.parse(a.data));

  return ListTile(
    leading: Icon(
      a.tanqueCheio ? Icons.local_gas_station : Icons.local_parking,
      color: a.tanqueCheio ? AppColors.infoFromTheme(context) : AppColors.grey,
    ),
    title: Text(
      '$date - ${a.tipoCombustivel} (${a.litrosAbastecidos.toStringAsFixed(2)} L)',
    ),
    subtitle: Text(
      'KM ${a.kmAtual} | Total: R\$ ${a.valorTotal.toStringAsFixed(2)}',
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Exibição da Média (Existente)
        Text(
          a.mediaCalculada != null
              ? 'Média: ${a.mediaCalculada!.toStringAsFixed(2)} km/l'
              : '',
          style: TextStyle(
            fontSize: 12,
            color: a.mediaCalculada != null
                ? AppColors.successFromTheme(context)
                : AppColors.warningFromTheme(context),
          ),
        ),
        const SizedBox(width: 8),
        // BOTÃO DE REMOÇÃO (NOVO)
        IconButton(
          icon: const Icon(
            Icons.delete,
            size: 20,
            color: AppColors.delete,
          ),
          onPressed: () => onDelete(a.id!, veiculoId),
        ),
      ],
    ),
    // REMOVIDO: onLongPress: () => _confirmDeleteAbastecimento(context, a.id!, veiculoId),
  );
}
