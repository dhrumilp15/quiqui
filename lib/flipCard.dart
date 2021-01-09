import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimationCard extends StatelessWidget {
  AnimationCard({this.child, this.animation});

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        var transform = Matrix4.identity();
        transform.setEntry(3, 2, 0.001);
        transform.rotateY(animation.value);
        return Transform(
            transform: transform, alignment: Alignment.center, child: child);
      },
      child: child,
    );
  }
}

typedef void BoolCallback(bool front);

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final int speed;
  final VoidCallback onFlip;
  final BoolCallback onFlipDone;

  const FlipCard(
      {Key key,
      @required this.front,
      @required this.back,
      this.speed = 500,
      this.onFlip,
      this.onFlipDone})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FlipCardState();
  }
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _frontRotation;
  Animation<double> _backRotation;

  bool isForward = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.speed));

    _frontRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
            tween: ConstantTween<double>(pi / 2), weight: 50.0)
      ],
    ).animate(_animationController);

    _backRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
            tween: ConstantTween<double>(pi / 2), weight: 50.0),
        TweenSequenceItem<double>(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        )
      ],
    ).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (widget.onFlipDone != null) widget.onFlipDone(isForward);

      }
    });
  }

  void flipCard() {
    if (widget.onFlip != null) {
      widget.onFlip();
    }

    if (isForward) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      isForward = !isForward;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.passthrough,
      children: <Widget>[_buildPanel(front: true), _buildPanel(front: false)],
    );
    return child;
  }

  Widget _buildPanel({bool front}) {
    return AnimationCard(
      animation: front ? _frontRotation : _backRotation,
      child: front ? widget.front : widget.back,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
