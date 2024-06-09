import 'package:firebase_database/firebase_database.dart';
import '../Class/pedido.dart';

class PedidoService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> createPedido(Pedido pedido) async {
    await _database.child('pedidos').child(pedido.id).set(pedido.toMap());
  }

  Future<List<Pedido>> readAllPedidos() async {
    DataSnapshot snapshot = await _database.child('pedidos').get();
    if (snapshot.exists) {
      Map<String, dynamic> pedidosMap = Map<String, dynamic>.from(snapshot.value as Map);
      return pedidosMap.values.map((pedido) => Pedido.fromMap(Map<String, dynamic>.from(pedido))).toList();
    } else {
      return [];
    }
  }

  Future<void> updatePedido(Pedido pedido) async {
    await _database.child('pedidos').child(pedido.id).update(pedido.toMap());
  }

  Future<void> deletePedido(String id) async {
    await _database.child('pedidos').child(id).remove();
  }
}
