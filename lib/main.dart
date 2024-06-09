import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:att_pedidos/firebase_options.dart';
import 'app/src/Services/pedido_service.dart';
import 'app/src/Class/pedido.dart';
import 'app/src/Views/create_pedido_page.dart';
import 'app/src/Views/update_pedido_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos Cliente',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,

      ),
      home: HomePage(),
      debugShowCheckedModeBanner: true,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PedidoService _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  Future<void> _fetchPedidos() async {
    List<Pedido> pedidos = await _pedidoService.readAllPedidos();
    setState(() {
      _pedidos = pedidos;
    });
  }

  Future<void> _navigateToUpdatePage(Pedido pedido) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdatePedidoPage(pedido: pedido)),
    );
    // Atualiza a lista após retornar da tela de atualização
    await _fetchPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
      ),
      body: _pedidos.isEmpty
          ? Center(
        child: Text('Nenhum pedido encontrado'),
      )
          : ListView.builder(
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          final pedido = _pedidos[index];
          return Card(
            child: ListTile(
              title: Text(pedido.cliente),
              subtitle: Text('Status: ${pedido.statusEntrega}'),
              onTap: () => _navigateToUpdatePage(pedido),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePedidoPage()),
          ).then((_) => _fetchPedidos()); // Atualiza a lista após o retorno
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
