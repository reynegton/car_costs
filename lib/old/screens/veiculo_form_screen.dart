// lib/screens/veiculo_form_screen.dart

import 'package:car_costs/core/currency_input_format.dart';
import 'package:car_costs/data/datasources/combustivel/combustivel_local_datasource_impl.dart';
import 'package:car_costs/data/models/combustivel/combustivel.dart';
import 'package:car_costs/data/repositories/combustivel/combustivel_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/veiculo/veiculo_bloc.dart';
import '../blocs/veiculo/veiculo_event.dart';
import '../models/veiculo.dart';

class VeiculoFormScreen extends StatefulWidget {
  final Veiculo? veiculo; // Se for nulo, é cadastro. Se não, é edição.

  const VeiculoFormScreen({super.key, required this.veiculo});

  @override
  State<VeiculoFormScreen> createState() => _VeiculoFormScreenState();
}

class _VeiculoFormScreenState extends State<VeiculoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Combustivel> _allCombustiveis = [];
  List<int> _selectedCombustivelIds = [];

  // Controladores para os campos do formulário
  late TextEditingController _nomeController;
  late TextEditingController _marcaController;
  late TextEditingController _anoController;
  late TextEditingController _capacidadeTanqueController;
  late TextEditingController _kmAtualController;
  late TextEditingController _mediaManualController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do veículo, se estiver em modo de edição
    _nomeController = TextEditingController(text: widget.veiculo?.nome ?? '');
    _marcaController = TextEditingController(text: widget.veiculo?.marca ?? '');
    _anoController = TextEditingController(
      text: widget.veiculo?.ano.toString() ?? '',
    );
    _capacidadeTanqueController = TextEditingController(
      text: widget.veiculo?.capacidadeTanqueLitros.toString() ?? '',
    );
    _kmAtualController = TextEditingController(
      text: widget.veiculo?.kmAtual.toString() ?? '0',
    );
    _mediaManualController = TextEditingController(
      text: widget.veiculo?.mediaManual.toString() ?? '0.0',
    );

    _loadCombustiveis();
  }

  @override
  void dispose() {
    // Limpar os controladores quando o widget for descartado
    _nomeController.dispose();
    _marcaController.dispose();
    _anoController.dispose();
    _capacidadeTanqueController.dispose();
    _kmAtualController.dispose();
    _mediaManualController.dispose();
    super.dispose();
  }

  Future<void> _loadCombustiveis() async {
    final repo = CombustivelRepositoryImpl(datasource: CombustivelLocalDatasourceImpl());
    final all = await repo.getAllCombustiveis();

    // NOVO: Se estiver editando, carrega os IDs aceitos
    List<int> acceptedIds = [];
    if (widget.veiculo != null && widget.veiculo!.id != null) {
      acceptedIds = await repo.getCombustivelIdsByVeiculo(widget.veiculo!.id!);
    }

    setState(() {
      _allCombustiveis = all;
      _selectedCombustivelIds = acceptedIds;
    });
  }

  // Função para salvar ou atualizar o veículo
  void _saveVeiculo() {
    if (_formKey.currentState!.validate()) {
      final isUpdating = widget.veiculo != null;

      final novoVeiculo = Veiculo(
        id: isUpdating ? widget.veiculo!.id : null,
        nome: _nomeController.text,
        marca: _marcaController.text,
        ano: int.tryParse(_anoController.text) ?? 2000,
        capacidadeTanqueLitros:
            double.tryParse(_capacidadeTanqueController.text) ?? 50.0,

        kmAtual: int.tryParse(_kmAtualController.text) ?? 0,
        mediaManual: double.tryParse(_mediaManualController.text) ?? 0.0,
      );

      if (isUpdating) {
        // Envia evento de atualização
        context.read<VeiculoBloc>().add(
          UpdateVeiculo(novoVeiculo, _selectedCombustivelIds),
        );
      } else {
        context.read<VeiculoBloc>().add(
          AddVeiculo(novoVeiculo, _selectedCombustivelIds),
        );
      }

      Navigator.of(context).pop(); // Volta para a tela de lista
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdating = widget.veiculo != null;
    final title = widget.veiculo == null ? 'Novo Veículo' : 'Editar Veículo';

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Nome do Veículo
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome/Apelido do Veículo',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              // Marca do Veículo
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              // Ano
              TextFormField(
                controller: _anoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ano de Fabricação',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              // Capacidade do Tanque (Litros)
              TextFormField(
                controller: _capacidadeTanqueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidade do Tanque (Litros)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              // KM Atual
              TextFormField(
                controller: _kmAtualController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'Quilometragem Atual',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              // Média Manual (Opcional no cadastro)
              TextFormField(
                controller: _mediaManualController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'Média Manual Inicial (Opcional)',
                ),
              ),

              const SizedBox(height: 20),

              // Tipo de Combustível (Apenas um campo simples por enquanto)
              _buildCombustivelSelection(),

              const SizedBox(height: 30),

              // Botão de Salvar
              ElevatedButton.icon(
                onPressed: _saveVeiculo,
                icon: const Icon(Icons.save),
                label: Text(isUpdating ? 'Atualizar' : 'Cadastrar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    50,
                  ), // Botão de largura total
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para seleção simples do tipo de combustível
  // NOVO WIDGET: Seleção Múltipla
  Widget _buildCombustivelSelection() {
    if (_allCombustiveis.isEmpty) {
      return const Center(child: Text('Carregando tipos de combustível...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Combustíveis Aceitos:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _allCombustiveis.map((comb) {
            final isSelected = _selectedCombustivelIds.contains(comb.id);
            return FilterChip(
              label: Text(comb.nome),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCombustivelIds.add(comb.id!);
                  } else {
                    _selectedCombustivelIds.remove(comb.id!);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
