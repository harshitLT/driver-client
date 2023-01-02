import 'dart:convert';

import 'package:client_app/payment_status_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Payment Management Driver Portal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isObscure = true;
  String phone = '', password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) => phone = value,
              onSubmitted: (value) => phone = value,
              decoration: const InputDecoration(
                  label: Text('Phone'), hintText: 'Phone'),
            ),
            TextField(
              obscureText: isObscure,
              onChanged: (value) => password = value,
              onSubmitted: (value) => password = value,
              decoration: InputDecoration(
                  label: const Text('Password'),
                  hintText: 'Password',
                  suffix: IconButton(
                    icon: Icon(
                        isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                  )),
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    Response response = await post(
                        Uri.parse(
                          'http://localhost:3000/v1/auth/login',
                        ),
                        body: {'phone': phone, 'password': password});
                    final Map<String, dynamic> body = jsonDecode(response.body);
                    if (response.statusCode != 200) {
                      Fluttertoast.showToast(msg: body['message']);
                      throw 'Something went wrong please try again';
                    }
                    Map<String, dynamic> decodedToken =
                        JwtDecoder.decode(body['accessToken']);

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: ((context) => PaymentStatusPage(
                            authToken: body['accessToken']))));
                  } on Exception catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }
                },
                child: const Text('Login'))
          ],
        ),
      ),
    );
  }
}
