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
						  imageJson: args.json,
						  zipName: args.zipName,
						  path: args.path
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

class RouteArgs {
	final Map<String, dynamic> json;
	final String zipName;
	final String path;

	RouteArgs(this.json, this.zipName, this.path);
}