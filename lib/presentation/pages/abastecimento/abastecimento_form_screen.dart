// lib/screens/abastecimento_form_screen.dart

import 'package:car_costs/core/currency_input_format.dart';
import 'package:car_costs/old/repositories/configuracao_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/abastecimento/abastecimento_bloc.dart';
import '../../blocs/abastecimento/abastecimento_event.dart';
import '../../blocs/combustivel/combustivel_bloc.dart';
import '../../blocs/combustivel/combustivel_event.dart';
import '../../blocs/combustivel/combustivel_state.dart';
import '../../../old/blocs/veiculo/veiculo_bloc.dart';
import '../../../old/blocs/veiculo/veiculo_state.dart';
import '../../../data/models/abastecimento/abastecimento.dart';
import '../../../old/models/veiculo.dart';
import '../../../data/models/combustivel/combustivel.dart';

class AbastecimentoFormScreen extends StatefulWidget {
  final Veiculo veiculo;

  const AbastecimentoFormScreen({super.key, required this.veiculo});

  @override
  State<AbastecimentoFormScreen> createState() =>
      _AbastecimentoFormScreenState();
}

class _AbastecimentoFormScreenState extends State<AbastecimentoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de Texto
  late TextEditingController _kmAtualController;
  late TextEditingController _litrosController;
  late TextEditingController _valorPorLitroController;
  late TextEditingController _valorTotalController;
  late TextEditingController _kmRodadaController;

  // Estado Interno (Minimizado)
  late DateTime _dataAbastecimento;
  String? _tipoCombustivelSelecionado;
  bool _tanqueCheio = true;
  // Semáforo para prevenir loops no cálculo 2 de 3
  bool _inCalculo = false;

  @override
  void initState() {
    super.initState();
    _dataAbastecimento = DateTime.now();

    // Inicializa controllers
    _kmAtualController = TextEditingController();
    _litrosController = TextEditingController();
    _valorPorLitroController = TextEditingController();
    _valorTotalController = TextEditingController();
    _kmRodadaController = TextEditingController();

    // Carrega a KM atual do VeiculoBloc
    _loadCurrentKm();

    // Dispara o carregamento de combustíveis (inclui o último usado)
    context.read<CombustivelBloc>().add(
      LoadCombustiveisData(widget.veiculo.id!),
    );

    _loadInitialConfig();

    // Adiciona Listeners
    _litrosController.addListener(()=>_recalculateValues('litros'));
    _valorPorLitroController.addListener(()=>_recalculateValues('litros'));
    _valorTotalController.addListener(()=>_recalculateValues('valorTotal'));
  }

  @override
  void dispose() {
    _litrosController.removeListener(()=>_recalculateValues('litros'));
    _valorPorLitroController.removeListener(()=>_recalculateValues('litros'));
    _valorTotalController.removeListener(()=>_recalculateValues('valorTotal'));

    _kmAtualController.dispose();
    _litrosController.dispose();
    _valorPorLitroController.dispose();
    _valorTotalController.dispose();
    _kmRodadaController.dispose();
    super.dispose();
  }

  void _loadInitialConfig() async {
    final repo = ConfiguracaoRepository();
    final isFullTank = await repo.getEncheuTanqueUltimoAbastecimento();
    
    // Atualiza o estado da tela (a única vez que o setState é usado para um estado global)
    setState(() {
      _tanqueCheio = isFullTank;
    });
  }

  // Função: Busca KM Atualizada (usando BLoC)
  void _loadCurrentKm() {
    final currentState = context.read<VeiculoBloc>().state;

    if (currentState is VeiculoLoaded) {
      try {
        final Veiculo veiculoAtualizado = currentState.veiculos.firstWhere(
          (v) => v.id == widget.veiculo.id,
        );
        _kmAtualController.text = veiculoAtualizado.kmAtual.toString();
      } catch (_) {
        _kmAtualController.text = widget.veiculo.kmAtual.toString();
      }
    } else {
      _kmAtualController.text = widget.veiculo.kmAtual.toString();
    }
  }

  // Função: Sumariza KM Rodada no KM Atual
  void _somarKmsRodada() {
    final kmRodada = int.tryParse(_kmRodadaController.text);

    if (kmRodada != null && kmRodada > 0) {
      final kmBase = widget.veiculo.kmAtual;
      final novaKm = kmBase + kmRodada;

      setState(() {
        _kmAtualController.text = novaKm.toString();
        _kmRodadaController.clear();
      });
    }
  }

  // Lógica de Cálculo (Baseada em Valor por Litro Fixo)
  void _recalculateValues(String origin) {
    // 1. Testa o semáforo
    if (!mounted || _inCalculo) return;

    // 2. Acende o semáforo
    _inCalculo = true;

    try {
      final litros =
          double.tryParse(_litrosController.text.replaceAll(',', '.')) ?? 0.0;
      final valorPL =
          double.tryParse(_valorPorLitroController.text.replaceAll(',', '.')) ??
          0.0;
      final valorTotal =
          double.tryParse(_valorTotalController.text.replaceAll(',', '.')) ??
          0.0;

      bool needsUpdate = false;
      const double tolerance = 0.01;

      // Só realiza cálculos se o Valor por Litro (a chave) estiver preenchido
      if (valorPL > 0) {
        if (origin == 'litros') {
          if (litros > 0) {
            final novoValorTotal = litros * valorPL;

            // Se o Valor Total está vazio ou precisa de atualização
            if (valorTotal == 0 ||
                (valorTotal - novoValorTotal).abs() > tolerance) {
              _valorTotalController.value = TextEditingValue(
                text: novoValorTotal.toStringAsFixed(2),
              );
              needsUpdate = true;
            }
          }
        }
        if (origin == 'valorTotal') {
          if (valorTotal > 0) {
            final novosLitros = valorTotal / valorPL;

            // Se Litros está vazio ou precisa de atualização
            if (litros == 0 || (litros - novosLitros).abs() > 0.001) {
              _litrosController.value = TextEditingValue(
                text: novosLitros.toStringAsFixed(3),
              );
              needsUpdate = true;
            }
          }
        }
      }

      if (needsUpdate) {
        setState(() {});
      }
    } finally {
      // 3. Desliga o semáforo
      _inCalculo = false;
    }
  }

  // Função de Submissão do Formulário
  void _saveAbastecimento() {
    if (!_formKey.currentState!.validate()) return;

    final litros =
        double.tryParse(_litrosController.text.replaceAll(',', '.')) ?? 0.0;
    final valorPL =
        double.tryParse(_valorPorLitroController.text.replaceAll(',', '.')) ??
        0.0;
    final valorTotal =
        double.tryParse(_valorTotalController.text.replaceAll(',', '.')) ?? 0.0;
    final kmAtual = int.tryParse(_kmAtualController.text) ?? 0;

    // Validação do KM
    if (kmAtual <= widget.veiculo.kmAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A KM Atual deve ser maior que a última KM registrada no veículo.',
          ),
        ),
      );
      return;
    }

    // Validação do combustível
    if (_tipoCombustivelSelecionado == null ||
        _tipoCombustivelSelecionado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de combustível.')),
      );
      return;
    }

    // Validação que ao menos Litros ou VTotal foi preenchido
    if (litros <= 0 && valorTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os Litros ou o Valor Total.')),
      );
      return;
    }

    // Cria o objeto Abastecimento
    final novoAbastecimento = Abastecimento(
      veiculoId: widget.veiculo.id!,
      data: DateFormat('yyyy-MM-dd').format(_dataAbastecimento),
      tipoCombustivel: _tipoCombustivelSelecionado!,
      kmAtual: kmAtual,
      litrosAbastecidos: litros,
      valorPorLitro: valorPL != 0.0 ? valorPL : valorTotal / litros,
      valorTotal: valorTotal,
      tanqueCheio: _tanqueCheio,
      mediaCalculada: null,
    );

    // 1. Envia o evento AddAbastecimento
    context.read<AbastecimentoBloc>().add(AddAbastecimento(novoAbastecimento));

    // 2. SALVA O COMBUSTÍVEL SELECIONADO COMO ÚLTIMO UTILIZADO
    final currentCombustivelId =
        (context.read<CombustivelBloc>().state as CombustivelLoaded)
            .combustiveisAceitos
            .firstWhere(
              (c) => c.nome == _tipoCombustivelSelecionado,
              orElse: () => Combustivel(nome: '', id: null),
            )
            .id;

    if (currentCombustivelId != null) {
      context.read<CombustivelBloc>().add(
        SetUltimoCombustivel(currentCombustivelId),
      );
    }

    Navigator.of(context).pop();
  }

  // -----------------------------------------------------------------
  // UI Building
  // -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Abastecimento: ${widget.veiculo.nome}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Título KM
              Text(
                'Quilometragem e Data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),

              // KM Atual (Valor Final)
              TextFormField(
                controller: _kmAtualController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'KM Atual no Abastecimento (Total)',
                  hintText: 'Obrigatório, deve ser maior que a última KM.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'A KM é obrigatória';
                  }                    
                  if (int.tryParse(value) == null) return 'KM inválida';
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // KM Rodada (para soma)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kmRodadaController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                      decoration: const InputDecoration(
                        labelText: 'KM Rodada (+N km)',
                        hintText: 'KM do hodômetro parcial (trip)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // BOTÃO DE ADIÇÃO (SOMA)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: ElevatedButton.icon(
                      onPressed: _somarKmsRodada,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Somar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Data do Abastecimento
              ListTile(
                title: Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(_dataAbastecimento)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dataAbastecimento,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _dataAbastecimento) {
                    setState(() {
                      _dataAbastecimento = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Título Valores
              Text(
                'Detalhes do Abastecimento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),

              // TIPO DE COMBUSTÍVEL (BlocBuilder)
              BlocBuilder<CombustivelBloc, CombustivelState>(
                builder: (context, state) {
                  if (state is CombustivelLoading) {
                    return const Center(child: LinearProgressIndicator());
                  }

                  if (state is CombustivelLoaded) {
                    // Define o valor inicial uma única vez
                    if (_tipoCombustivelSelecionado == null) {
                      final ultimoId = state.ultimoCombustivelId;
                      final ultimoObj = state.combustiveisAceitos.firstWhere(
                        (c) => c.id == ultimoId,
                        orElse: () => state.combustiveisAceitos.isNotEmpty
                            ? state.combustiveisAceitos.first
                            : Combustivel(nome: '', id: null),
                      );
                      _tipoCombustivelSelecionado = ultimoObj.nome;
                    }

                    if (state.combustiveisAceitos.isEmpty) {
                      return const Text(
                        'Nenhum combustível aceito configurado para este veículo.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Combustível',
                      ),
                      initialValue: _tipoCombustivelSelecionado,
                      items: state.combustiveisAceitos.map((
                        Combustivel combustivel,
                      ) {
                        return DropdownMenuItem<String>(
                          value: combustivel.nome,
                          child: Text(combustivel.nome),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoCombustivelSelecionado = newValue;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Selecione o tipo'
                          : null,
                    );
                  }

                  return const SizedBox();
                },
              ),
              const SizedBox(height: 10),

              // VALOR POR LITRO (AGORA É CAMPO CHAVE E OBRIGATÓRIO)
              TextFormField(
                controller: _valorPorLitroController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'Valor por Litro (R\$)',
                  hintText: 'Obrigatório para o cálculo.',
                ),
              ),
              const SizedBox(height: 10),

              // Litros Abastecidos (Calculável)
              TextFormField(
                controller: _litrosController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'Litros Abastecidos',
                  hintText: 'Calculado se o Valor Total for informado.',
                ),
              ),
              const SizedBox(height: 10),

              // Valor Total (Calculável)
              TextFormField(
                controller: _valorTotalController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [CurrencyInputFormatterFreeEdit(decimalPrecision: 2)],
                decoration: const InputDecoration(
                  labelText: 'Valor Total (R\$)',
                  hintText: 'Calculado se Litros for informado.',
                ),
              ),

              const SizedBox(height: 20),

              // Tanque Cheio?
              SwitchListTile(
                title: const Text('Tanque Cheio'),
                subtitle: const Text(
                  'Marque se este abastecimento encheu o tanque.',
                ),
                value: _tanqueCheio,
                onChanged: (bool value) {
                  setState(() {
                    _tanqueCheio = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Botão de Salvar
              ElevatedButton.icon(
                onPressed: _saveAbastecimento,
                icon: const Icon(Icons.save),
                label: const Text('Registrar Abastecimento'),
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
