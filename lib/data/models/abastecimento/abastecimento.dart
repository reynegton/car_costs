// lib/models/abastecimento.dart

class Abastecimento {
  int? id;
  int veiculoId;
  String data; // Armazenado como String no formato ISO8601 (ex: '2025-11-21')
  String tipoCombustivel;
  int kmAtual;
  double litrosAbastecidos;
  double valorPorLitro;
  double valorTotal;
  bool tanqueCheio;
  double?
  mediaCalculada; // A média calculada entre este abastecimento e o último 'tanque cheio'

  Abastecimento({
    this.id,
    required this.veiculoId,
    required this.data,
    required this.tipoCombustivel,
    required this.kmAtual,
    required this.litrosAbastecidos,
    required this.valorPorLitro,
    required this.valorTotal,
    required this.tanqueCheio,
    this.mediaCalculada,
  });

  // Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'data': data,
      'tipoCombustivel': tipoCombustivel,
      'kmAtual': kmAtual,
      'litrosAbastecidos': litrosAbastecidos,
      'valorPorLitro': valorPorLitro,
      'valorTotal': valorTotal,
      'tanqueCheio': tanqueCheio
          ? 1
          : 0, // SQLite armazena booleanos como 0 ou 1
      'mediaCalculada': mediaCalculada,
    };
  }

  // Cria a partir do Map
  factory Abastecimento.fromMap(Map<String, dynamic> map) {
    return Abastecimento(
      id: map['id'],
      veiculoId: map['veiculoId'],
      data: map['data'],
      tipoCombustivel: map['tipoCombustivel'],
      kmAtual: map['kmAtual'],
      litrosAbastecidos: map['litrosAbastecidos'],
      valorPorLitro: map['valorPorLitro'],
      valorTotal: map['valorTotal'],
      tanqueCheio: map['tanqueCheio'] == 1,
      mediaCalculada: map['mediaCalculada'],
    );
  }
}
