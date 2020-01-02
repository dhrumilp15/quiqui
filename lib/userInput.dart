import 'package:flutter/material.dart';
import 'dart:core';

import 'package:quiqui/imagehandler.dart';
import 'package:quiqui/Dog.dart';
import 'package:quiqui/typedefs.dart';

typedef onSubmitCallback = void Function(Dog userAnswer);

class userInput extends StatefulWidget {
	final onSubmitCallback onSubmit;

	userInput({this.onSubmit});

	@override
  _userInputState createState() => _userInputState();
}

class _userInputState extends State<userInput> {
	final GlobalKey _formKey = GlobalKey<FormState>();
	Dog userAnswer = Dog(name: '', file: '', details: {});
	final List<String> info = ImageHandler().getInfo();

  @override
  void initState() {
  	super.initState();
  }

  @override
  void dispose() {
  	super.dispose();
  }



	@override
  Widget build(BuildContext context) {
  	var rows = buildListOfRows();
		  return Form(
						key: _formKey,
						child: SingleChildScrollView(
								child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: <Widget>[
									...rows,
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceEvenly,
										children: <Widget>[
											Padding(
													padding: const EdgeInsets.symmetric(vertical: 5.0),
													child: RaisedButton(
														onPressed: () {
															// Validate returns true if the form is valid, or false
															// otherwise.
															// If the form is valid, display a Snackbar.
															FormState form = _formKey.currentState;

															if (form.validate()) {
																form.save();
																widget.onSubmit(userAnswer);
																form.reset();
																Scaffold.of(context)
																		.showSnackBar(SnackBar(content: Text('Processing Data')));
															}
														},
														color: Colors.blue,
														child: Text(
																'Submit',
																style: TextStyle(color: Colors.white)
														),
													)
											),
											Padding(
													padding: const EdgeInsets.symmetric(vertical: 5.0),
													child: RaisedButton(
														onPressed: () {
															widget.onSubmit(null);
															FormState form = _formKey.currentState;
															form.reset();
															Scaffold.of(context)
																	.showSnackBar(
																		SnackBar(
																				content: Text('Oh noes! That\'s ok!'),
																			action: SnackBarAction(
																				label: 'Dismiss',
																				textColor: Colors.yellow,
																				onPressed: () {
																					Scaffold.of(context).hideCurrentSnackBar();
																				}
																			)
																		)
																);
														},
														color: Colors.cyan,
														child: Text(
																'Don\'t Know',
																style: TextStyle(color: Colors.white)
														),
													)
											),
										],
									),

								]
							)
						),
		);
  }

  List<Widget> buildListOfRows() {
	  var rows = new List<Widget>();

	  for (int i = 0; i < (info.length/2).ceil() + 1; i += 2) {
		  rows.add(
				  Row(
					  mainAxisAlignment: (i + 1 < info.length) ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
					  children: <Widget>[
						  Flexible(
							  child: TextFormField(
									  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
									  decoration: InputDecoration(
											  border: InputBorder.none,
											  labelText: getLabelText(i),
											  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)
									  ),

									  validator: (value) {
										  if (value.isEmpty) {
											  return 'Please enter this dog\'s ${info[i]}';
										  }
									  },

									  onChanged: (text) {
									  	print(text);
									  },

									  onSaved: (val) {
									  	if (info[i] == 'name') {
									  		userAnswer.setName(val);
										  } else {
									  		userAnswer.details[info[i]] = val;
										  }
									  }
							  ),
						  ),
						  (i + 1 < info.length) ?
						  Flexible(
								  child: TextFormField(
										  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
										  decoration: InputDecoration(
												  border: InputBorder.none,
												  labelText: getLabelText(i + 1),
												  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)
										  ),

										  validator: (value) {
											  if (value.isEmpty) {
												  return 'Please enter this dog\'s ${info[i + 1]}';
											  }
										  },

										  onChanged: (text) { // for debug purposes :_(
											  print(text);
										  },

										  onSaved: (val) {
										  	if (info[i+1] == 'name') {
												  userAnswer.setName(val);
											  } else {
												  userAnswer.details[info[i + 1]] = val;
											  }
										  }
								  )
						  ) : Container(height: 0)
					  ],
				  )
		  );
	  }
  	return rows;
  }

  String getLabelText(int index) {
  	return info[index][0].toUpperCase() + info[index].substring(1);
  }


}