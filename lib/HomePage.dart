import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pomodoro/Activity.dart';
import 'package:pomodoro/ActivityWidget.dart';
import 'package:pomodoro/StartedActivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String title = "Pomodoro";

  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Activity> activities;
  var _controller = PageController(initialPage: 0, keepPage: false);
  String _title = "Random activity";
  double _sliderValue = 30;

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
                      return ActivityWidget(
                          activities[index].title, activities[index].duration);
                    },
                  )),
        floatingActionButton: FloatingActionButton(
          tooltip: 'New Activity',
          child: Icon(Icons.add),
          onPressed: () {
            _controller.animateToPage(0,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          },
        ));
  }

  Widget newActivityPage() {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

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
                activeColor: Colors.redAccent,
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
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => StartedActivity(
            (_title == "") ? "Random activiy" : _title,
            _sliderValue.toInt())));

    // Back from StartedActivity
    if (result != null)
      setState(() {
        activities.add(result);
        Future.delayed(Duration(milliseconds: 1000)); // make it smoother
        _controller.animateToPage(1,
            duration: Duration(milliseconds: 1000), curve: Curves.ease);
      });
  }

  @override
  void initState() {
    super.initState();
    _read();
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
        result.add(Activity(el['title'], el['duration'], el['startedAt'], el['completed']));
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
