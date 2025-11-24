// lib/models/veiculo_combustivel.dart

// Tabela de junção para Many-to-Many
class VeiculoCombustivel {
  final int veiculoId;
  final int combustivelId;

  VeiculoCombustivel({required this.veiculoId, required this.combustivelId});

  Map<String, dynamic> toMap() {
    return {'veiculoId': veiculoId, 'combustivelId': combustivelId};
  }

  factory VeiculoCombustivel.fromMap(Map<String, dynamic> map) {
    return VeiculoCombustivel(
      veiculoId: map['veiculoId'],
      combustivelId: map['combustivelId'],
    );
  }
}
