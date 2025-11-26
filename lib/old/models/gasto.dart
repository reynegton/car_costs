// lib/models/gasto.dart

class Gasto {
  final String
  id; // ID Único (ex: 'A_1' para Abastecimento 1 ou 'M_5' para Manutenção 5)
  final String tipo; // 'Abastecimento' ou 'Manutencao'
  final String data; // Data do gasto
  final double valor; // Valor total do gasto
  final String
  descricao; // Descrição do gasto (Ex: Tipo de combustível ou serviço)

  Gasto({
    required this.id,
    required this.tipo,
    required this.data,
    required this.valor,
    required this.descricao,
  });
}
