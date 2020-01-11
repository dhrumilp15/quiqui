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
import 'package:quiqui/LandingPage.dart';
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
	GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
	GlobalKey<countdownTimerState> timerKey = GlobalKey<countdownTimerState>();
	final GlobalKey formKey = GlobalKey<FormState>();
	bool waiting = false;


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
//		print('widget.imageJson: ${widget.imageJson}');

		quiz = Quiz(widget.imageJson);

		Timer.periodic(Duration(milliseconds: 20), onTick); // Update the app every 20 ms
	}

	void onTick(Timer timer) {
		setState(() {});
	}

	void check(BuildContext context, Dog userAnswer) {
//		print("userAnswer.map: " + userAnswer?.map.toString());
//		print("quiz.getDog(quiz.dogIndex).map" + quiz.getDog(quiz.dogIndex).map.toString());
		if (userAnswer == null) {
			dontKnow(context);
		}
		else if (DeepCollectionEquality().equals(userAnswer?.map, quiz.getDog(quiz.dogIndex).map)) { // because identical() did not work
//			Scaffold.of(context)
//					.showSnackBar(SnackBar(content: Text('Nice!')));
			FormState form = formKey.currentState;
			form.reset();
			quiz.correct();
			FocusScope.of(context).unfocus();
			timerKey.currentState.reset();
			timerKey.currentState.start();
		}
	}

	void dontKnow(BuildContext context) {
		if (!waiting) {
			waiting = true;
//			Scaffold.of(context).showSnackBar(SnackBar(content: Text('Oh noes! That\'s ok!')));
			timerKey.currentState.stop();
//			print("unlucky - that's wrong");
			if (cardKey.currentState.isForward) cardKey.currentState.flipCard();

			Future.delayed(Duration(seconds: 2), () {
				cardKey.currentState.flipCard();
				if (cardKey.currentState.isForward) Future.delayed(Duration(milliseconds: 200), () => quiz.incorrect());
				timerKey.currentState.reset();
				timerKey.currentState.start();
				waiting = false;
			}); // Give the player 5 seconds to realize their mistake
		}
	}

	@override
	Widget build(BuildContext context) {
//		print('waiting: $waiting');
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
														Padding(
															padding: EdgeInsets.only(top: 5.0),
															child: Row(
																	mainAxisAlignment: MainAxisAlignment.center,
																	children: <Widget>[
//																		countdown(this._current)
																		countdownTimer(
																			key: timerKey,
																			onFinish: () => dontKnow(context),
																		)
																	]
															)
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
													formKey: formKey,
													quiz: quiz,
													info: widget.imageJson["info"],
													onSubmit: (Dog userAnswer) => check(context, userAnswer)
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