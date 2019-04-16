import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Pomodoro Technique")),
      body: WebView(
        initialUrl: "https://en.wikipedia.org/wiki/Pomodoro_Technique",
      ),
    );
  }
}
