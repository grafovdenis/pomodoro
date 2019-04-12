import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro/Activity.dart';
import 'package:pomodoro/Wave/Wave.dart';

class StartedActivity extends StatefulWidget {
  StartedActivity(String title, int duration) {
    this.activity = new Activity(title, duration,
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()), true);
  }

  Activity activity;

  @override
  _StartedActivityState createState() => _StartedActivityState();
}

class _StartedActivityState extends State<StartedActivity>
    with TickerProviderStateMixin {
  AnimationController controller;

  int secondsRemains;
  Timer _timer;

  void startTimer() {
    secondsRemains = widget.activity.duration * 60;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (secondsRemains < 1) {
                timer.cancel();
                Navigator.of(context).pop(widget.activity);
              } else {
                // TODO set secondsRemains--
                secondsRemains = secondsRemains - 300;
              }
            }));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void _showDialog() async {
    if (secondsRemains != 0) {
      await Future.delayed(Duration(milliseconds: 100)); // make it smoother
      showDialog(
        context: context,
        builder: (context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Stop current activity?"),
            content:
                new Text("Are you sure you wish to stop current activity?\n"
                    "Your progress will be lost!"),
            actions: <Widget>[
              new FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(); // close alert
                  }),
              // usually buttons at the bottom of the dialog
              new FlatButton(
                  child: new Text("Stop"),
                  onPressed: () async {
                    Navigator.of(context).pop(); // close alert
                    await Future.delayed(
                        Duration(milliseconds: 100)); // make it smoother
                    Navigator.of(context).pop(new Activity(
                        widget.activity.title,
                        widget.activity.duration - secondsRemains ~/ 60,
                        widget.activity.startedAt,
                        false));
                  }),
            ],
          );
        },
      );
    } else
      Navigator.of(context).pop(widget.activity);
  }

  @override
  Widget build(BuildContext context) {
    Size size = new Size(MediaQuery.of(context).size.width, 300.0);
    int minutesRemains = secondsRemains ~/ 60;
    double waveHeight = MediaQuery.of(context).size.height *
        (widget.activity.duration * 60 - secondsRemains) /
        (widget.activity.duration * 60);
    //double waveHeight = 300;

    return WillPopScope(
      onWillPop: () {},
      child: Scaffold(
        body: Stack(children: <Widget>[
          new ColorCurveBody(
              size: size,
              xOffset: 0,
              yOffset: 0,
              color: Colors.blue[100],
              height: waveHeight),
          new ColorCurveBody(
              size: size,
              xOffset: 20,
              yOffset: 0,
              color: Colors.blue,
              height: waveHeight),
          Center(
              child: Text(
                  "${minutesRemains.toString().padLeft(2, '0')}:${(secondsRemains % 60).toInt().toString().padLeft(2, '0')}",
                  textScaleFactor: 3)),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Align(
              alignment: FractionalOffset.topCenter,
              child: Text(widget.activity.title, textScaleFactor: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(50),
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: RaisedButton(
                  child: const Text("Stop"), onPressed: () => _showDialog()),
            ),
          )
        ]),
      ),
    );
  }
}
