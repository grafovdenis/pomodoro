import 'package:flutter/material.dart';
import 'package:pomodoro/HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pomodoro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => new HomePage(),
        },
    );
  }
}
