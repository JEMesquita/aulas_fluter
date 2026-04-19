class Product {
  final int? id;
  final String nome;
  final String descricao;
  final double preco;

  const Product({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final precoValue = map['preco'];
    final parsedpreco = precoValue is int ? precoValue.toDouble() : precoValue as double;

    return Product(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      preco: parsedpreco,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
    };
  }
}
