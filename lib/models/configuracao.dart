// lib/models/configuracao.dart (Atualizado)

class Configuracao {
  int id;
  int mediaApuracaoN;
  int? veiculoIdSelecionado;
  int? ultimoCombustivelId; // NOVO: ID do último combustível usado

  Configuracao({
    this.id = 1,
    this.mediaApuracaoN = 3,
    this.veiculoIdSelecionado,
    this.ultimoCombustivelId, // NOVO
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mediaApuracaoN': mediaApuracaoN,
      'veiculoIdSelecionado': veiculoIdSelecionado,
      'ultimoCombustivelId': ultimoCombustivelId, // NOVO
    };
  }

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      id: map['id'],
      mediaApuracaoN: map['mediaApuracaoN'],
      veiculoIdSelecionado: map['veiculoIdSelecionado'],
      ultimoCombustivelId: map['ultimoCombustivelId'],
    );
  }
}
