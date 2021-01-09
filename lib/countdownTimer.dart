import 'package:flutter/material.dart';
import 'dart:math';

class CountDownTimer extends StatefulWidget {
  final VoidCallback onFinish;

  CountDownTimer({Key key, this.onFinish}) : super(key: key);

  @override
  CountDownTimerState createState() => CountDownTimerState();
}

class CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController controller;
  final int totalTime = 30;
  AnimationStatus status;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalTime),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void start() {
    controller.forward();
  }

  void stop() {
    controller.stop();
  }

  void reset() {
    controller.reset();
  }

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${totalTime - duration.inSeconds}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
            fit: FlexFit.loose,
            child: Align(
                alignment: FractionalOffset.center,
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 40.0),
                    child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(children: <Widget>[
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (BuildContext context, Widget child) {
                                return CustomPaint(
                                    painter: CustomTimerPainter(
                                  animation: controller,
                                  backgroundColour: Colors.red,
                                  colour: Colors.black,
                                ));
                              },
                            ),
                          ),
                          Align(
                              alignment: FractionalOffset.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  AnimatedBuilder(
                                      animation: controller,
                                      builder: (context, child) {
                                        return Text(
                                          timerString,
                                        );
                                      })
                                ],
                              ))
                        ])))))
      ],
    ));
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    this.animation,
    this.backgroundColour,
    this.colour,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColour, colour;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColour
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = colour;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        colour != old.colour ||
        backgroundColour != old.backgroundColour;
  }
}
