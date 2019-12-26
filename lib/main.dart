import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'quiz.dart';
import 'dart:async';
import 'package:quiqui/assets/images.dart';
import 'package:quiver/async.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
	return MaterialApp(
	  title: 'Flutter Demo',
	  theme: ThemeData(
		primarySwatch: Colors.blue,
	  ),
	  home: MyHomePage(),
	);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var quiz;
  int _start = 10;
  int _current = 10;
  var sub;

  @override
	void initState() {
  	super.initState();
  	initQuiz();
	}

	void initQuiz() {
  	quiz = Quiz();
  	Timer.periodic(Duration(milliseconds: 20), onTick);
  	try {
		  this.sub.cancel();
	  } catch (stackTrace) {print(stackTrace);}
		  initTimer();
		  startTimer();
	  }

	void onTick(Timer timer) {
  	setState(() {});
	}

	void initTimer() {
  	_start = 10;
  	_current = 10;
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
			showAlertDialog(context);
			sub.cancel();
		});
	}

	void showAlertDialog(BuildContext context) {
	  Widget gotIt = FlatButton(
			  child: Text('Got it!'),
			  onPressed: () {
				  quiz.incorrect();
				  this.sub.cancel();
				  initTimer();
				  Navigator.of(context).pop();
				  startTimer();
			  }
	  );

	  AlertDialog alert = AlertDialog(
		  title: Text("Answer"),
		  content: Text(
				  'This dog\'s name is ${quiz.getDog(quiz.dogIndex).getName()}'),
		  actions: [
			  gotIt,
		  ],
	  );

	  showDialog(
			  context: context,
			  builder: (BuildContext context) {
				  return alert;
			  }
	  );
  }

	@override
  Widget build(BuildContext context) {
  	return Scaffold(
			    appBar: AppBar(
				    title: Text('Dogs: Qui, Qui (Who is Who)'),
			    ),
			    body: Column(
					    children: <Widget>[
						    Stack(
							    children: <Widget>[
								    Container(
									    child: (quiz.dogs.length > 0) ? ImageView(quiz.getDog(quiz.dogIndex).getFile()) : ImageView('lib/assets/images/icon.png'),
								    ),
								    (quiz.dogs.length > 0) ? countDown(_current) : Container(height:0)
							    ]
						    ),
						    Divider(),
						    Column(
								    mainAxisAlignment: MainAxisAlignment.center,
								    children: (quiz.dogs.length > 0) ? [yesNo(quiz,this)] : [finalPage(quiz, this)]
						    )
					    ]
			    )
	    );
    }
  }

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

class ImageView extends StatelessWidget {
  final String file;
  final double dimension = 305.0;
  ImageView(this.file);

  @override
  Widget build(BuildContext context) {
  	return Container(
	    padding: EdgeInsets.only(top : 50.0, bottom: 50.0),
        child: Row(
		        mainAxisAlignment: MainAxisAlignment.center,
		        children: <Widget>[
		        	Container(
				          width:dimension,
					        height: dimension,
					        decoration: BoxDecoration(
				            borderRadius: BorderRadius.circular(8.0),
				            border: Border.all(
					            color: Colors.blue,
					            width: 5.0
				            ),
							        image: DecorationImage(
								        image: ExactAssetImage(file),
								        fit: BoxFit.fill,
					        )
                ),
              )
      ]
    )
    );
  }
}

class yesNo extends StatelessWidget {
  final Quiz quiz;
  final _MyHomePageState MyHomePageState;

  yesNo(this.quiz, this.MyHomePageState);

	@override
  Widget build(BuildContext context) {
    return Container(
		    child: Row(
				    mainAxisAlignment: MainAxisAlignment.center,
				    children: <Widget>[
					    ButtonTheme(
						    minWidth: MediaQuery
								    .of(context)
								    .size
								    .width / 2,
						    height: 200,
						    child: RaisedButton(
							    onPressed: () {
								    quiz.correct();
								    if (quiz.dogs.length > 0) {
									    MyHomePageState.sub.cancel();
									    MyHomePageState.initTimer();
									    MyHomePageState.startTimer();
								    }
							    },
							    color: Colors.green,
							    child: Icon(Icons.check),
						    ),
					    ),
					    ButtonTheme(
						    minWidth: MediaQuery
								    .of(context)
								    .size
								    .width / 2,
						    height: 200,
						    child: RaisedButton(
							    onPressed: () {
								    if (quiz.dogs.length > 0)
									    MyHomePageState.showAlertDialog(context);
								    else
									    null;
							    },
							    color: Colors.red,
							    child: Icon(Icons.close),
						    ),
					    )
				    ]
		    )
    );
  }
}

class finalPage extends StatelessWidget {
	final Quiz quiz;
	final _MyHomePageState MyHomePageState;
	finalPage(this.quiz, this.MyHomePageState);

	@override
  Widget build(BuildContext context) {
    return Container(
	    child: Column(
			    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
			    children: [
				    Text(
						    'You got ${quiz.getScore()} out of ${images.json['dogs'].length} correct!',
						    style: TextStyle(fontSize: 20.0)
				    ),
				    Text(
						    '',
						    style: TextStyle(fontSize: 20.0)
				    ),
				    ButtonTheme(
						    child: RaisedButton(
								    child: Text(
										    'Retry?',
										    style: TextStyle(color: Colors.white)
								    ),
								    onPressed: () {
									    MyHomePageState.initQuiz();
								    }
						    )
				    ),
			    ]
	    )
    );
  }
}
