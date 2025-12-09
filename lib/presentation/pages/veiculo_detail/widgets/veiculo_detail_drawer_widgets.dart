import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_costs/core/app_colors.dart';
import 'package:car_costs/core/theme_controller.dart';
import 'package:car_costs/domain/repositories/configuracao/configuracao_repository.dart';
import 'package:car_costs/presentation/pages/veiculo/veiculo_list_screen.dart';

import '../../../../data/models/veiculo/veiculo.dart';
import '../veiculo_detail_screen.dart';

Widget buildDrawerHeader(BuildContext context, Veiculo currentVeiculo) {
  return UserAccountsDrawerHeader(
    accountName: Text(currentVeiculo.nome),
    accountEmail: Text(
      '${currentVeiculo.marca} | KM: ${currentVeiculo.kmAtual}',
    ),
    currentAccountPicture: const Icon(
      Icons.directions_car,
      size: 48,
      color: AppColors.white,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
    ),
  );
}

Widget buildDrawerVeiculoList(
  BuildContext context,
  List<Veiculo> allVeiculos,
  Veiculo currentVeiculo,
) {
  return ListView(
    children: allVeiculos.map((v) {
      return ListTile(
        leading: v.id == currentVeiculo.id
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.directions_car),
        title: Text(v.nome),
        selected: v.id == currentVeiculo.id,
        onTap: () async {
          Navigator.of(context).pop(); // Fecha o Drawer

          if (v.id != currentVeiculo.id) {
            // 1. SALVAR NOVA PREFERÊNCIA
            final configRepo = context.read<ConfiguracaoRepository>();
            await configRepo.setVeiculoSelecionado(v.id!);

            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => VeiculoDetailScreen(veiculo: v),
                ),
              );
            }
          }
        },
      );
    }).toList(),
  );
}

Widget buildDrawerThemeSection(
  BuildContext context,
  ThemeController themeController,
  ThemeMode currentMode,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(
                'Sistema',
                style: TextStyle(
                  color: currentMode == ThemeMode.system
                      ? AppColors.textOnPrimary
                      : AppColors.chipLabel,
                ),
              ),
              selected: currentMode == ThemeMode.system,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.chipBackground,
              showCheckmark: true,
              checkmarkColor: AppColors.textOnPrimary,
              onSelected: (_) =>
                  themeController.setThemeMode(ThemeMode.system),
            ),
            ChoiceChip(
              label: Text(
                'Claro',
                style: TextStyle(
                  color: currentMode == ThemeMode.light
                      ? AppColors.textOnPrimary
                      : AppColors.chipLabel,
                ),
              ),
              selected: currentMode == ThemeMode.light,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.chipBackground,
              showCheckmark: true,
              checkmarkColor: AppColors.textOnPrimary,
              onSelected: (_) =>
                  themeController.setThemeMode(ThemeMode.light),
            ),
            ChoiceChip(
              label: Text(
                'Escuro',
                style: TextStyle(
                  color: currentMode == ThemeMode.dark
                      ? AppColors.textOnPrimary
                      : AppColors.chipLabel,
                ),
              ),
              selected: currentMode == ThemeMode.dark,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.chipBackground,
              showCheckmark: true,
              checkmarkColor: AppColors.textOnPrimary,
              onSelected: (_) =>
                  themeController.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildDrawerManageVeiculosTile(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.list),
    title: const Text('Gerenciar Veículos'),
    onTap: () {
      Navigator.of(context).pop(); // Fecha o Drawer
      // Volta para a lista principal de cadastro/seleção
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const VeiculoListScreen(),
        ),
        (Route<dynamic> route) => false, // Remove todas as rotas anteriores
      );
    },
  );
}
