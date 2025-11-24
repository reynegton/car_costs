// lib/screens/manutencao_screen.dart

import 'package:car_costs/screens/manutencao_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/veiculo.dart';
import '../blocs/manutencao/manutencao_bloc.dart';
import '../blocs/manutencao/manutencao_event.dart';
import '../blocs/manutencao/manutencao_state.dart';

class ManutencaoScreen extends StatelessWidget {
  final Veiculo veiculo;
  final bool
  showFab; // Este campo não será mais necessário, mas o mantemos para evitar erros de compilação temporários

  const ManutencaoScreen({
    super.key,
    required this.veiculo,
    this.showFab = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Carregar a lista de manutenções ao abrir a aba
    context.read<ManutencaoBloc>().add(LoadManutencoes(veiculo.id!));

    // RETORNA UM WIDGET DE CONTEÚDO, NÃO UM SCAFFOLD COMPLETO
    return BlocBuilder<ManutencaoBloc, ManutencaoState>(
      builder: (context, state) {
        if (state is ManutencaoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ManutencaoError) {
          return Center(
            child: Text('Erro ao carregar manutenções: ${state.message}'),
          );
        }

        if (state is ManutencaoLoaded) {
          if (state.manutencoes.isEmpty) {
            return const Center(
              child: Text('Nenhum registro de manutenção. Adicione um novo!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: state.manutencoes.length,
            itemBuilder: (context, index) {
              final m = state.manutencoes[index];
              final date = DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime.parse(m.data));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.build_circle, color: Colors.indigo),
                  title: Text(m.descricao),
                  subtitle: Text(
                    '$date | Valor: R\$ ${m.valor.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Exibição da Média (Existente)
                      Text(
                        'KM: ${veiculo.kmAtual}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      // BOTÃO DE REMOÇÃO (NOVO)
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ManutencaoFormScreen(
                                veiculo: veiculo,
                                manutencao:
                                    m, // Passa o objeto para o formulário
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _confirmDeleteManutencao(
                          context,
                          m.id!,
                          veiculo.id!,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }

  // Função para confirmar a exclusão (mantida)
  void _confirmDeleteManutencao(
    BuildContext context,
    int manutencaoId,
    int veiculoId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja deletar este registro de manutenção?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ManutencaoBloc>().add(
                DeleteManutencao(manutencaoId, veiculoId),
              );
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}
