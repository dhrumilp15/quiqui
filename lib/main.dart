import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';

//other files
import 'package:quiqui/LandingPage.dart';
import 'package:quiqui/MyHomePage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
	return MaterialApp(
	  title: 'Qui Qui',
	  home: LandingPage(),

		onGenerateRoute: (settings) { // So that we can pass the Json to MyHomePage()
	  	if (settings.name == MyHomePage.routeName) {
	  		final RouteArgs args = settings.arguments;

	  		return MaterialPageRoute(
				  builder: (context) {
				  	return MyHomePage(
						  imageJson: args.json
					  );
				  }
			  );
		  }
		},
	  theme: ThemeData(
			primarySwatch: Colors.blue,
	  ),
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

class RouteArgs {
	final Map<String, dynamic> json;

	RouteArgs(this.json);
}