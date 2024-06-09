class Pedido {
  String id;
  String cliente;
  String enderecoDestino;
  String produto;
  String dataEntregaPrevista;
  String localizacaoAtual;
  String statusEntrega;

  Pedido({
    required this.id,
    required this.cliente,
    required this.enderecoDestino,
    required this.produto,
    required this.dataEntregaPrevista,
    required this.localizacaoAtual,
    required this.statusEntrega,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'enderecoDestino': enderecoDestino,
      'produto': produto,
      'dataEntregaPrevista': dataEntregaPrevista,
      'localizacaoAtual': localizacaoAtual,
      'statusEntrega': statusEntrega,
    };
  }

  static Pedido fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      cliente: map['cliente'],
      enderecoDestino: map['enderecoDestino'],
      produto: map['produto'],
      dataEntregaPrevista: map['dataEntregaPrevista'],
      localizacaoAtual: map['localizacaoAtual'],
      statusEntrega: map['statusEntrega'],
    );
  }
}

