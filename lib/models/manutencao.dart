// lib/models/manutencao.dart

class Manutencao {
  int? id;
  int veiculoId;
  String data; // Armazenado como String (ex: '2025-11-21')
  double valor;
  String descricao; // O que foi feito

  Manutencao({
    this.id,
    required this.veiculoId,
    required this.data,
    required this.valor,
    required this.descricao,
  });

  // Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'data': data,
      'valor': valor,
      'descricao': descricao,
    };
  }

  // Cria a partir do Map
  factory Manutencao.fromMap(Map<String, dynamic> map) {
    return Manutencao(
      id: map['id'],
      veiculoId: map['veiculoId'],
      data: map['data'],
      valor: map['valor'],
      descricao: map['descricao'],
    );
  }
}
