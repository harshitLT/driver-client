import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class PaymentStatusPage extends StatefulWidget {
  final String authToken;
  const PaymentStatusPage({super.key, required this.authToken});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  List<Map<String, dynamic>> paymentRequests = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    IO.Socket socket = IO.io(
        'http://localhost:3000',
        OptionBuilder().setExtraHeaders({
          'Access-Control-Allow-Origin': '*',
          'authorization': widget.authToken,
        }).build());
    socket.onConnect((_) {
      print('connect');
    });
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.authToken);
    socket.on(
        decodedToken['userId'],
        (data) => setState(() {
              paymentRequests.add(data);
            }));
    socket.onDisconnect((_) async {
      try {
        Response response = await post(
            Uri.parse(
              'http://localhost:3000/v1/auth/logout',
            ),
            headers: {'authorization': 'Bearer ${widget.authToken}'});
        if (response.statusCode != 200) {
          final Map<String, dynamic> body1 = jsonDecode(response.body);
          Fluttertoast.showToast(msg: body1['message']);
          throw 'Something went wrong please try again';
        }
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'Socket disconnected');
      } on Exception catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: paymentRequests.isEmpty
            ? const Center(
                child: Text('Waiting for data'),
              )
            : ListView.builder(
                itemCount: paymentRequests.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) => Text(
                      paymentRequests[index].toString(),
                    )),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            Response response = await post(
                Uri.parse(
                  'http://localhost:3000/v1/auth/logout',
                ),
                headers: {'authorization': 'Bearer ${widget.authToken}'});
            if (response.statusCode != 200) {
              final Map<String, dynamic> body1 = jsonDecode(response.body);
              Fluttertoast.showToast(msg: body1['message']);
              throw 'Something went wrong please try again';
            }
            Navigator.of(context).pop();
          } on Exception catch (e) {
            Fluttertoast.showToast(msg: e.toString());
          }
        },
        child: const Text('Logout'),
      ),
    );
  }
}
