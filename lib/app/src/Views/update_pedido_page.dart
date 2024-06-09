import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/pedido_service.dart';
import '../Class/pedido.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdatePedidoPage extends StatefulWidget {
  final Pedido pedido;

  UpdatePedidoPage({required this.pedido});

  @override
  _UpdatePedidoPageState createState() => _UpdatePedidoPageState();
}

class _UpdatePedidoPageState extends State<UpdatePedidoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clienteController;
  late TextEditingController _enderecoDestinoController;
  late TextEditingController _produtoController;
  late TextEditingController _dataEntregaPrevistaController;
  late TextEditingController _localizacaoAtualController;
  late TextEditingController _statusEntregaController;
  DateTime? _selectedDate;

  final String apiKey = '89475887877264262327x586';

  @override
  void initState() {
    super.initState();
    _clienteController = TextEditingController(text: widget.pedido.cliente);
    _enderecoDestinoController = TextEditingController(text: widget.pedido.enderecoDestino);
    _produtoController = TextEditingController(text: widget.pedido.produto);
    _dataEntregaPrevistaController = TextEditingController(text: widget.pedido.dataEntregaPrevista);
    _localizacaoAtualController = TextEditingController(text: widget.pedido.localizacaoAtual);
    _statusEntregaController = TextEditingController(text: widget.pedido.statusEntrega);
  }

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _dataEntregaPrevistaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('');
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
      Pedido updatedPedido = Pedido(
        id: widget.pedido.id,
        cliente: _clienteController.text,
        enderecoDestino: _enderecoDestinoController.text,
        produto: _produtoController.text,
        dataEntregaPrevista: _dataEntregaPrevistaController.text,
        localizacaoAtual: _localizacaoAtualController.text,
        statusEntrega: _statusEntregaController.text,
      );

      await PedidoService().updatePedido(updatedPedido);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido atualizado com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atualizar Pedido'),
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
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectDate(context);
                },
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
                child: Text('Atualizar Pedido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
