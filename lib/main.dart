import 'package:flutter/material.dart';
import 'scroll_wheel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Wheel Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'Scroll Wheel Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    double _wheelDia =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.height * 0.8;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              key: scrollWheelKey,
              width: _wheelDia,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ScrollWheel(
                    diameter: _wheelDia,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
