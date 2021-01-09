import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:collection/collection.dart';

//other files
import 'package:quiqui/AnswerView.dart';
import 'package:quiqui/countdownTimer.dart';
import 'package:quiqui/Dog.dart';
import 'package:quiqui/finalPage.dart';
import 'package:quiqui/flipCard.dart';
import 'package:quiqui/ImageView.dart';
import 'package:quiqui/quiz.dart';
import 'package:quiqui/userInput.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/HomePage';

  MyHomePage({Key key, this.imageJson, this.zipName, this.path})
      : super(key: key);

  final Map<String, dynamic> imageJson;
  final String zipName;
  final String path;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Quiz quiz;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  GlobalKey<CountDownTimerState> timerKey = GlobalKey<CountDownTimerState>();
  final GlobalKey formKey = GlobalKey<FormState>();
  bool waiting = false;
  String path;

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
    quiz = Quiz(widget.imageJson, widget.zipName);
    Timer.periodic(
        Duration(milliseconds: 20), onTick); // Update the app every 20 ms
  }

  void onTick(Timer timer) {
    setState(() {});
  }

  void check(BuildContext context, Dog userAnswer) {
    if (userAnswer == null ||
        !DeepCollectionEquality()
            .equals(userAnswer?.map, quiz.getDog(quiz.dogIndex).map)) {
      dontKnow(context);
    } else {
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
      FormState form = formKey.currentState;
      form.reset();
      FocusScope.of(context).unfocus();
      timerKey.currentState.stop();
      if (cardKey.currentState.isForward) cardKey.currentState.flipCard();

      Future.delayed(Duration(seconds: 2), () {
        cardKey.currentState.flipCard();
        if (cardKey.currentState.isForward) Future.delayed(Duration(milliseconds: 200), () => quiz.incorrect());
        timerKey.currentState.reset();
        timerKey.currentState.start();
      });
      waiting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Qui Qui - Learn Faster With Flashcards'),
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.max, children: [
          Stack(children: <Widget>[
            (quiz.dogs.length > 0)
                ? Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CountDownTimer(
                            key: timerKey,
                            onFinish: () => dontKnow(context),
                          )
                        ]))
                : Container(height: 0),
            (quiz.dogs.length > 0)
                ? FlipCard(
                    key: cardKey,
                    front: ImageView(quiz.getDog(quiz.dogIndex).getFile,
                        widget.zipName, widget.path),
                    back: AnswerView(quiz.getDog(quiz.dogIndex)),
                  )
                : ImageView(
                    'lib/assets/images/icon.png', widget.zipName, widget.path),
          ]),
          Divider(),
          (quiz.dogs.length > 0)
              ? UserInput(
                  formKey: formKey,
                  quiz: quiz,
                  info: widget.imageJson["info"],
                  onSubmit: (Dog userAnswer) => check(context, userAnswer))
              : FinalPage(quiz: quiz, onRetry: () => initQuiz())
        ]))));
  }
}
