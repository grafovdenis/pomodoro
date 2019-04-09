import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as Vector;

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList = [];

  WaveClipper(this.animation, this.waveList);

  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.addPolygon(waveList, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}

class ColorCurveBody extends StatefulWidget {
  final Size size;
  final int xOffset;
  final int yOffset;
  final Color color;

  double height;

  ColorCurveBody(
      {Key key,
      @required this.size,
      this.xOffset,
      this.yOffset,
      this.color,
      this.height})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ColorCurveBodyState();
}

class _ColorCurveBodyState extends State<ColorCurveBody>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<Offset> animList = [];

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));

    animationController.addListener(() {
      animList.clear();
      for (int i = -2 - widget.xOffset;
          i <= widget.size.width.toInt() + 2;
          i++) {
        animList.add(new Offset(
            i.toDouble() + widget.xOffset,
            sin((animationController.value * 360 - i) %
                        360 *
                        Vector.degrees2Radians) *
                    20 +
                50 +
                widget.yOffset));
      }
    });
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.bottomCenter,
      child: new AnimatedBuilder(
          animation: new CurvedAnimation(
              parent: animationController, curve: Curves.easeInOut),
          builder: (context, child) => new ClipPath(
                child: new Container(
                  width: widget.size.width,
                  height: 30 + widget.height,
                  color: widget.color,
                ),
                clipper: new WaveClipper(animationController.value, animList),
              )),
    );
  }
}
