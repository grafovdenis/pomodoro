import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/About.dart';
import 'package:pomodoro/Activity.dart';
import 'package:pomodoro/StartedActivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  final String title = "Pomodoro";

  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel('grafa.pomodoro/calendar');
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  List<Activity> activities;
  static var _controller = PageController(initialPage: 0, keepPage: false);
  String _title = "Random activity";

  double _sliderValue = 30;

  Future<void> _addCalendarEvent(String event) async {
    try {
      await platform.invokeMethod("insertToCalendar", {"event": event});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Widget bottomButton(context) => FloatingActionButton(
        tooltip: 'New Activity',
        child: Text("?", textScaleFactor: 2),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => About()));
        },
      );

  void _showDialog(String event) async {
    Future.delayed(Duration(milliseconds: 100)); // make it smoother
    showDialog(
      context: context,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Add to calendar?"),
          content: new Text("The calendar will open as new page."),
          actions: <Widget>[
            new FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // close alert
                }),
            // usually buttons at the bottom of the dialog
            new FlatButton(
                child: new Text("Add"),
                onPressed: () async {
                  Future.delayed(
                      Duration(milliseconds: 100)); // make it smoother
                  _addCalendarEvent(event);
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Widget activitiesPage() {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: (activities.isEmpty)
                ? Text(
                    "You had none activities.\nWould you like to create new one?",
                    textAlign: TextAlign.center)
                : ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = activities[index];
                      return Container(
                        child: Dismissible(
                          child: Card(
                            child: ListTile(
                              leading: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: item.completed
                                    ? Icon(Icons.check_circle_outline)
                                    : Icon(Icons.radio_button_unchecked),
                              ),
                              title: Text(item.title),
                              subtitle: Text("${item.duration} minutes"),
                              onTap: (() {}),
                            ),
                          ),
                          background: Container(
                              child: Icon(Icons.delete), color: Colors.red[300]),
                          key: Key(item.toString()),
                          onDismissed: (direction) {
                            setState(() {
                              activities.removeAt(index);
                              _save();
                              Future.delayed(Duration(milliseconds: 1000));
                              _read();
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text("${item.title} dismissed")));
                            });
                          },
                        ),
                      );
                    },
                  )),
        floatingActionButton: bottomButton(context));
  }

  Widget newActivityPage() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Start new activity", textScaleFactor: 2),
            SizedBox(height: deviceHeight * 0.08),
            Container(
              width: deviceWidth * 0.8,
              child: TextField(
                onChanged: (text) => _title = text,
                decoration: InputDecoration(
                    hintText: "Your activity title",
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.blueGrey[800])),
              ),
            ),
            SizedBox(height: deviceHeight * 0.08),
            Container(
              width: deviceWidth * 0.8,
              child: Slider(
                activeColor: Colors.blue[200],
                inactiveColor: Colors.black12,
                value: _sliderValue,
                min: 10,
                max: 100,
                onChanged: (double value) {
                  setState(() => _sliderValue = value);
                },
                divisions: 9,
                label: '${_sliderValue.round()}',
              ),
            ),
            SizedBox(height: deviceHeight * 0.08),
            RaisedButton(
              child: const Text("Start"),
              onPressed: () {
                _navigateAndDisplaySelection(context);
              },
            )
          ],
        ),
      ),
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final Activity result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => StartedActivity(
            (_title == "") ? "Done something" : _title, _sliderValue.toInt())));

    // Back from StartedActivity
    if (result != null)
      setState(() {
        activities.add(result);
        String event = result.toString();
        _showDialog(event);
        Future.delayed(Duration(milliseconds: 1000)); // make it smoother
        _controller.animateToPage(1,
            duration: Duration(milliseconds: 1000), curve: Curves.ease);
      });
  }

  @override
  void initState() {
    super.initState();
    _read();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print('on message $message');
        },
        onResume: (Map<String, dynamic> message) {
          print('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) {
          print('on launch $message');
        }
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token){
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: <Widget>[newActivityPage(), activitiesPage()],
    );
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    _save();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _read() async {
    if (activities == null) activities = List.of([]);
    final prefs = await SharedPreferences.getInstance();
    final key = 'activities';
    final value = await jsonDecode(prefs.getString(key) ?? "[]");
    final List<Activity> result = List.of([]);

    if (value.toString() != "[]") {
      for (Map<String, dynamic> el in value) {
        result.add(Activity(
            el['title'], el['duration'], el['startedAt'], el['completed']));
      }
    }
    print("Read $value");
    setState(() {
      activities = result;
    });
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'activities';
    final value =
        jsonEncode(activities.map((activity) => activity.toJson()).toList());
    prefs.setString(key, value);
    print("Saved $value");
  }
}
