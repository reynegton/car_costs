// lib/models/veiculo.dart

class Veiculo {
  int? id;
  String nome;
  String marca;
  int ano;
  double capacidadeTanqueLitros;
  List<int> combustivelIdsAceitos = const [];
  double mediaManual; // Média que pode ser informada e atualizada pelo sistema
  double mediaLongPrazo; // NOVO: Média das últimas N médias
  int kmAtual; // Quilometragem atual do veículo
  int
  kmUltimoNivel; // KM em que o último nível (ou tanque cheio) foi registrado
  double litrosNoTanque; // Litros estimados ou ajustados manualmente

  Veiculo({
    this.id,
    required this.nome,
    required this.marca,
    required this.ano,
    required this.capacidadeTanqueLitros,

    this.mediaManual = 0.0,
    this.kmAtual = 0,
    this.kmUltimoNivel = 0,
    this.litrosNoTanque = 0.0,
    this.mediaLongPrazo = 0.0,
  });

  // Converte um objeto Veiculo para um Map (útil para o sqflite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'marca': marca,
      'ano': ano,
      'capacidadeTanqueLitros': capacidadeTanqueLitros,

      'mediaManual': mediaManual,
      'kmAtual': kmAtual,
      'kmUltimoNivel': kmUltimoNivel,
      'litrosNoTanque': litrosNoTanque,
      'mediaLongPrazo': mediaLongPrazo,
    };
  }

  // Cria um objeto Veiculo a partir de um Map (útil para o sqflite)
  factory Veiculo.fromMap(Map<String, dynamic> map) {
    return Veiculo(
      id: map['id'],
      nome: map['nome'],
      marca: map['marca'],
      ano: map['ano'],
      capacidadeTanqueLitros: map['capacidadeTanqueLitros'],

      mediaManual: map['mediaManual'],
      kmAtual: map['kmAtual'] ?? 0,
      kmUltimoNivel: map['kmUltimoNivel'] ?? 0,
      litrosNoTanque: map['litrosNoTanque'] ?? 0.0,
      mediaLongPrazo: map['mediaLongPrazo'] ?? 0.0,
    );
  }
}
