// lib/screens/veiculo_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/veiculo/veiculo_bloc.dart';
import '../../blocs/veiculo/veiculo_event.dart';
import '../../blocs/veiculo/veiculo_state.dart';
import '../../../data/models/veiculo/veiculo.dart';
import '../../../data/repositories/configuracao/configuracao_repository_impl.dart';
import 'veiculo_form_screen.dart';
import '../veiculo_detail/veiculo_detail_screen.dart';

class VeiculoListScreen extends StatelessWidget {
  const VeiculoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Quando a tela é construída, disparamos o evento para carregar a lista
    context.read<VeiculoBloc>().add(LoadVeiculos());

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 Selecione seu Veículo'),
        centerTitle: true,
      ),
      body: BlocBuilder<VeiculoBloc, VeiculoState>(
        builder: (context, state) {
          if (state is VeiculoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VeiculoError) {
            return Center(child: Text('Erro ao carregar: ${state.message}'));
          }

          if (state is VeiculoLoaded) {
            if (state.veiculos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nenhum veículo cadastrado.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Cadastre o primeiro veículo para começar o gerenciamento.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VeiculoFormScreen(veiculo: null),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Novo Veículo'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.veiculos.length,
              itemBuilder: (context, index) {
                final veiculo = state.veiculos[index];
                return _buildVeiculoCard(context, veiculo);
              },
            );
          }

          return const Center(child: Text('Aguardando dados...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de formulário para adicionar um novo
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const VeiculoFormScreen(veiculo: null),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget para exibir os detalhes de um veículo em um Card
  Widget _buildVeiculoCard(BuildContext context, Veiculo veiculo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.directions_car, size: 40),
        title: Text('${veiculo.nome} (${veiculo.marca})'),
        subtitle: Text('Ano: ${veiculo.ano} | KM Atual: ${veiculo.kmAtual}km'),

        // ----------------------------------------------------
        // AÇÕES NO TRAILING: Edição e Exclusão
        // ----------------------------------------------------
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Ícone para EDIÇÃO
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              tooltip: 'Editar Veículo',
              onPressed: () {
                // Navega para a tela de formulário para EDIÇÃO
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VeiculoFormScreen(veiculo: veiculo),
                  ),
                );
              },
            ),
            // 2. Ícone para DELETAR
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Deletar Veículo',
              onPressed: () => _confirmDelete(context, veiculo),
            ),
          ],
        ),

        // ----------------------------------------------------
        // AÇÃO NO Toque: SELECIONAR VEÍCULO e ir para o DASHBOARD
        // ----------------------------------------------------
        onTap: () async {
          // 1. SALVA O VEÍCULO SELECIONADO COMO ÚLTIMO UTILIZADO
          final configRepo = ConfiguracaoRepositoryImpl();
          await configRepo.setVeiculoSelecionado(veiculo.id!);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VeiculoDetailScreen(veiculo: veiculo),
              ),
            );
          }
        },
      ),
    );
  }

  // Função para confirmar a exclusão
  void _confirmDelete(BuildContext context, Veiculo veiculo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja deletar o veículo ${veiculo.nome} e todos os seus registros de abastecimento/manutenção?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Envia o evento DeleteVeiculo para o BLoC
              context.read<VeiculoBloc>().add(DeleteVeiculo(veiculo.id!));
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
