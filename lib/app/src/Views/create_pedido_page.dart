import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/pedido_service.dart';
import '../Class/pedido.dart';

class CreatePedidoPage extends StatefulWidget {
  @override
  _CreatePedidoPageState createState() => _CreatePedidoPageState();
}

class _CreatePedidoPageState extends State<CreatePedidoPage> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _enderecoDestinoController = TextEditingController();
  final _produtoController = TextEditingController();
  final _dataEntregaPrevistaController = TextEditingController();
  final _localizacaoAtualController = TextEditingController();
  final _statusEntregaController = TextEditingController();

  final String apiKey = '89475887877264262327x586';

  @override
  void dispose() {
    _clienteController.dispose();
    _enderecoDestinoController.dispose();
    _produtoController.dispose();
    _dataEntregaPrevistaController.dispose();
    _localizacaoAtualController.dispose();
    _statusEntregaController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          '');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print("Current position: ${position.latitude}, ${position.longitude}");

    try {
      String url = 'https://geocode.xyz/${position.latitude},${position.longitude}?geoit=json&auth=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Geocode.xyz response: $data");

        setState(() {
          _localizacaoAtualController.text =
          '${data['staddress'] ?? ''}, ${data['city'] ?? ''}, ${data['state'] ?? ''}, ${data['country'] ?? ''}';
        });

        print("Address: ${_localizacaoAtualController.text}");
      } else {
        print("");
        setState(() {
          _localizacaoAtualController.text =
          '${position.latitude}, ${position.longitude}';
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _localizacaoAtualController.text =
        '${position.latitude}, ${position.longitude}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Pedido pedido = Pedido(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cliente: _clienteController.text,
        enderecoDestino: _enderecoDestinoController.text,
        produto: _produtoController.text,
        dataEntregaPrevista: _dataEntregaPrevistaController.text,
        localizacaoAtual: _localizacaoAtualController.text,
        statusEntrega: _statusEntregaController.text,
      );

      await PedidoService().createPedido(pedido);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido criado com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Pedido'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _clienteController,
                decoration: InputDecoration(labelText: 'Cliente'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do cliente';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _enderecoDestinoController,
                decoration: InputDecoration(labelText: 'Endereço de Destino'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o endereço de destino';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _produtoController,
                decoration: InputDecoration(labelText: 'Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o produto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataEntregaPrevistaController,
                decoration: InputDecoration(
                  labelText: 'Data de Entrega Prevista',
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data de entrega prevista';
                  }
                  return null;
                },
                keyboardType: TextInputType.datetime,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _localizacaoAtualController,
                      decoration: InputDecoration(labelText: 'Localização Atual'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a localização atual';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.location_searching),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
              TextFormField(
                controller: _statusEntregaController,
                decoration: InputDecoration(labelText: 'Status da Entrega'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o status da entrega';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Criar Pedido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
