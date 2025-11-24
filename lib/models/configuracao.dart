// lib/models/configuracao.dart (Atualizado)

class Configuracao {
  int id;
  int mediaApuracaoN;
  int? veiculoIdSelecionado;
  int? ultimoCombustivelId; 
  bool encheuTanqueUltimoAbastecimento;

  Configuracao({
    this.id = 1,
    this.mediaApuracaoN = 3,
    this.veiculoIdSelecionado,
    this.ultimoCombustivelId, 
    this.encheuTanqueUltimoAbastecimento = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mediaApuracaoN': mediaApuracaoN,
      'veiculoIdSelecionado': veiculoIdSelecionado,
      'ultimoCombustivelId': ultimoCombustivelId, 
      'encheuTanqueUltimoAbastecimento': encheuTanqueUltimoAbastecimento ? 1 : 0,
    };
  }

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      id: map['id'],
      mediaApuracaoN: map['mediaApuracaoN'],
      veiculoIdSelecionado: map['veiculoIdSelecionado'],
      ultimoCombustivelId: map['ultimoCombustivelId'],
      encheuTanqueUltimoAbastecimento: map['encheuTanqueUltimoAbastecimento'] == 1,
    );
  }
}
