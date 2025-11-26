// lib/screens/manutencao_form_screen.dart

import 'package:car_costs/core/currency_input_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/manutencao/manutencao_bloc.dart';
import '../blocs/manutencao/manutencao_event.dart';
import '../models/manutencao.dart';
import '../models/veiculo.dart';

class ManutencaoFormScreen extends StatefulWidget {
  final Veiculo veiculo;
  final Manutencao? manutencao; // NOVO: Objeto de manutenção para edição (pode ser nulo)

  const ManutencaoFormScreen({super.key, required this.veiculo, this.manutencao});

  @override
  State<ManutencaoFormScreen> createState() => _ManutencaoFormScreenState();
}

class _ManutencaoFormScreenState extends State<ManutencaoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _valorController;
  late TextEditingController _descricaoController;
  late DateTime _dataManutencao;

  // Variável de controle
  bool get isEditing => widget.manutencao != null;

  @override
  void initState() {
    super.initState();
    // Se estiver editando, usa os dados existentes
    if (isEditing) {
      _valorController = TextEditingController(text: widget.manutencao!.valor.toStringAsFixed(2));
      _descricaoController = TextEditingController(text: widget.manutencao!.descricao);
      _dataManutencao = DateTime.parse(widget.manutencao!.data);
    } else {
      // Caso contrário, inicializa do zero
      _valorController = TextEditingController();
      _descricaoController = TextEditingController();
      _dataManutencao = DateTime.now();
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _saveManutencao() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O valor deve ser maior que zero.')),
      );
      return;
    }

    // Cria o objeto de manutenção (usando o ID existente se estiver editando)
    final novaManutencao = Manutencao(
      id: isEditing ? widget.manutencao!.id : null, // Mantém o ID se estiver editando
      veiculoId: widget.veiculo.id!,
      data: DateFormat('yyyy-MM-dd').format(_dataManutencao),
      valor: valor,
      descricao: _descricaoController.text,
    );

    if (isEditing) {
      // Envia evento de ATUALIZAÇÃO
      context.read<ManutencaoBloc>().add(UpdateManutencao(novaManutencao));
    } else {
      // Envia evento de ADIÇÃO
      context.read<ManutencaoBloc>().add(AddManutencao(novaManutencao));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditing ? 'Editar Manutenção' : 'Registrar Manutenção';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Data da Manutenção
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(_dataManutencao)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dataManutencao,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _dataManutencao) {
                    setState(() {
                      _dataManutencao = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),

              // Valor
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'Valor Total (R\$)',
                  prefixText: 'R\$ ',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),

              // Descrição
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'O que foi feito? (Descrição)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Descreva o serviço realizado' : null,
              ),
              const SizedBox(height: 30),

              // Botão de Salvar
              ElevatedButton.icon(
                onPressed: _saveManutencao,
                icon: const Icon(Icons.build),
                label: const Text('Salvar Manutenção'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
