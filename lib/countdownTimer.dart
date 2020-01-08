import 'package:flutter/material.dart';
import 'dart:math';

class countdownTimer extends StatefulWidget {
  @override
  _countdownTimerState createState() => _countdownTimerState();
}

class _countdownTimerState extends State<countdownTimer> with TickerProviderStateMixin{
	AnimationController controller;
	final int totalTime = 30;

	@override
	void initState() {
		super.initState();
		controller = AnimationController(
			vsync: this,
			duration: Duration(seconds: totalTime),
		);
	}

	@override
  Widget build(BuildContext context) {
		ThemeData themeData = Theme.of(context);
		return Container(
					child: Stack(
						children: <Widget>[
							Positioned.fill(
									child: AnimatedBuilder(
											animation: controller,
											builder: (BuildContext context, Widget child) {
												return CustomPaint(
													painter: CustomTimerPainter(
															animation: controller,
															backgroundColour: Colors.white,
															colour: themeData.indicatorColor
													),
												);
											}
											)
							)
						],
					)
		);
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
			..strokeWidth = 10.0
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