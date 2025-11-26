// lib/models/combustivel.dart

class Combustivel {
  int? id;
  String nome; // Ex: Gasolina, Etanol

  Combustivel({this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  factory Combustivel.fromMap(Map<String, dynamic> map) {
    return Combustivel(id: map['id'], nome: map['nome']);
  }
}
