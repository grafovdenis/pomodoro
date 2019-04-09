import 'package:flutter/material.dart';

class ActivityWidget extends StatelessWidget {
  String title;
  int duration;

  ActivityWidget(String title, int duration) {
    this.title = title;
    this.duration = duration;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text("$duration minutes"),
        onTap: (() {}),
      ),
    );
  }
}
