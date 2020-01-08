import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:quiver/async.dart';
import 'dart:core';
import 'package:collection/collection.dart';

//other files
import 'package:quiqui/AnswerView.dart';
import 'package:quiqui/quiz.dart';
import 'package:quiqui/flipCard.dart';
import 'package:quiqui/ImageView.dart';
import 'package:quiqui/userInput.dart';
import 'package:quiqui/Dog.dart';
import 'package:quiqui/finalPage.dart';
import 'package:quiqui/main.dart';
import 'package:quiqui/countdownTimer.dart';

class MyHomePage extends StatefulWidget {
	static const routeName = '/HomePage';

	MyHomePage({Key key, this.imageJson}) : super(key : key);

	final Map<String, dynamic> imageJson;

	@override
	_MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
	Quiz quiz;
	static final int totalTime = 20;
	int _start = totalTime;
	int _current = totalTime;
	var sub;
	GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

	@override
	void initState() {
		super.initState();
		initQuiz();
	}

	@override
	void dispose() {
		super.dispose();
	}

	void initQuiz() async {
		print('widget.imageJson: ${widget.imageJson}');

		quiz = Quiz(widget.imageJson);

		Timer.periodic(Duration(milliseconds: 20), onTick); // Update the app every 20 ms

		this.sub?.cancel();

		initTimer();
		startTimer();
	}

	void onTick(Timer timer) {
		setState(() {});
	}

	void initTimer() {
		_start = totalTime;
		_current = totalTime;
	}

	void startTimer() {
		CountdownTimer countDownTimer = new CountdownTimer(
			new Duration(seconds: _start),
			new Duration(seconds: 1),
		);

		this.sub = countDownTimer.listen(null);
		sub.onData((duration) {
			setState(() { _current = _start - duration.elapsed.inSeconds; });
		});

		sub.onDone(() {
			dontKnow();
			sub.cancel();
		});
	}

	void check(Dog userAnswer) {
		print("userAnswer.map: " + userAnswer?.map.toString());
		print("quiz.getDog(quiz.dogIndex).map" + quiz.getDog(quiz.dogIndex).map.toString());


		if (DeepCollectionEquality().equals(userAnswer?.map, quiz.getDog(quiz.dogIndex).map)) { // because identical() did not work
			print('THAT WAS RIGHT');
			this.sub.cancel();
			initTimer();
			quiz.correct();
			startTimer();
		} else {
			dontKnow();
		}
	}

	void dontKnow() {
		print("unlucky - that's wrong");
		this.sub.cancel();
		cardKey.currentState.flipCard();
//		Scaffold.of(context)
//				.showSnackBar(SnackBar(content: Text('Oh noes!')));
		Future.delayed(Duration(seconds: 5), () {
			cardKey.currentState.flipCard();
			initTimer();
			if (cardKey.currentState.isForward) quiz.incorrect();
			startTimer();
		}); // Give the player 5 seconds to realize their mistake
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
				appBar: AppBar(
					title: Text('Qui Qui'),
				),
				body: SingleChildScrollView(
						child: Center(
								child: Column(
										mainAxisSize: MainAxisSize.max,
										children: [
											Stack(
													children: <Widget>[
														(quiz.dogs.length > 0) ?
														Positioned(
															top: 15,
															right: MediaQuery.of(context).size.width/2,
															child: countDown(this._current)
														) : Container(height:0),
														(quiz.dogs.length > 0) ?
														FlipCard(
															key: cardKey,
															front: ImageView(quiz.getDog(quiz.dogIndex).getFile),
															back: AnswerView(quiz.getDog(quiz.dogIndex)),
														)
																: ImageView('lib/assets/images/icon.png'),
													]
											),
											Divider(), // this is fine.
											(quiz.dogs.length > 0) ?
											userInput(
													onSubmit: (Dog userAnswer) => check(userAnswer),
													info: widget.imageJson["info"]
											) :
											finalPage(
													quiz: quiz,
													onRetry: () => initQuiz()
											)
										]
								)
						)
				)
		);
	}
}