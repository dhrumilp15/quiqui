import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:quiver/async.dart';
import 'dart:core';

import 'package:quiqui/AnswerView.dart';
import 'package:quiqui/quiz.dart';
import 'package:quiqui/flipCard.dart';
import 'package:quiqui/ImageView.dart';
import 'package:quiqui/userInput.dart';
import 'package:quiqui/Dog.dart';
import 'package:collection/collection.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
	return MaterialApp(
	  title: 'Qui Qui',
	  theme: ThemeData(
			primarySwatch: Colors.blue,
	  ),
	  home: MyHomePage(),
	);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Quiz quiz;
  static final int totalTime = 45;
  int _start = totalTime;
  int _current = totalTime;
  var sub;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  GlobalKey<MyHomePageState> mainKey = GlobalKey<MyHomePageState>(); // I'm sorry I don't know how to fix this... :_(

  @override
	void initState() {
  	super.initState();
  	initQuiz();
	}

	@override
	void dispose() {
  	super.dispose();
	}

	void initQuiz() {
		quiz = Quiz();
		Timer.periodic(Duration(milliseconds: 20), onTick); // Update the app every 20 ms

		try {
			this.sub.cancel();
		} catch (stackTrace) {
			print(stackTrace);
		}
		
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
					    child: Column(
					      children: <Widget>[
								    Column(
									    children: <Widget>[
										    Stack(
												    children: <Widget>[
													    (quiz.dogs.length > 0) ? countDown(_current) : Container(height:0),
													    Container(
														    child: (quiz.dogs.length > 0) ?
														    FlipCard(
															    key: cardKey,
															    front: ImageView(quiz.getDog(quiz.dogIndex).getFile),
															    back: AnswerView(quiz.getDog(quiz.dogIndex)),
														    )
																    : ImageView('lib/assets/images/icon.png'),
													    ),
												    ]
										    ),
										    Divider(),
										    (quiz.dogs.length > 0) ? userInput(
												    onSubmit: (Dog userAnswer) {
												    	check(userAnswer);
												    }
										    ) : finalPage(quiz)
									    ]
								    )
					      ]
							    )
						    )
			    );
    }
  }
  typedef onSubmitCallback = void Function(Dog userAnswer);


class countDown extends StatelessWidget {
  int _current;

  countDown(this._current);

	@override
  Widget build(BuildContext context) {
    return Container(
	    child: Positioned(
		    top: 15,
		    right: MediaQuery
				    .of(context)
				    .size
				    .width / 2,
		    child: Text(
				    '$_current',
				    style: (_current > 5) ? TextStyle(color: Colors.black) : TextStyle(color: Colors.red)
		    ),
	    )
    );
  }
}

class finalPage extends StatelessWidget {
	final Quiz quiz;
	finalPage(this.quiz);

	@override
	Widget build(BuildContext context) {
		return
				Column(
						mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						children: [
							Text(
									'You got ${quiz.getScore} out of ${quiz.total} correct!',
									style: TextStyle(fontSize: 20.0)
							),
							ButtonTheme(
									child: RaisedButton(
											child: Text(
													'Retry?',
													style: TextStyle(color: Colors.white)
											),
											onPressed: () {
												Provider.of<MyHomePageState>(context).initQuiz();
											}
									)
							),
						]
//				)
		);
	}
}