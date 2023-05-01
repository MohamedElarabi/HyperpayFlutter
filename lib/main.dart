import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic platform = const MethodChannel('hyperPay.dev/startPayment');
  void _openPaymentSdk() {
    if (kDebugMode) {
      print("Start Payment  -=-=-=-=> ");
    }
    setState(() {
      platform = const MethodChannel('hyperPay.dev/startPayment');
    });
    platform.invokeMethod('createPayment',
        {"price": "19.90", "brand": "APPLEPAY", "user": "1"}).then((result) {
      if (kDebugMode) {
        print("pay done -=-=-=-=> $result");
      }

      if (result["Status"] == "Error") {
        var snackBar = const SnackBar(content: Text('Server Error'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      if (result["Status"] == "Error_Payment") {
        var snackBar = const SnackBar(content: Text("Error_Payment"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      setState(() {
        platform = null;
      });
    }).catchError((err) {
      if (kDebugMode) {
        print("pay ssssssssssssssss -=-=-=-=> $err");
      }
    });
  }

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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              "",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openPaymentSdk();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
