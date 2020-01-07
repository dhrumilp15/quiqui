import 'package:flutter/material.dart';
import 'dart:core';

import 'package:quiqui/imagehandler.dart';
import 'package:quiqui/Dog.dart';

typedef onSubmitCallback = void Function(Dog userAnswer);

class userInput extends StatefulWidget {
	final onSubmitCallback onSubmit;
	final List info;

	userInput({this.onSubmit, this.info});

	@override
  _userInputState createState() => _userInputState();
}

class _userInputState extends State<userInput> {
	final GlobalKey _formKey = GlobalKey<FormState>();

	Dog _userAnswer = Dog(name: '', file: '', details: {});

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
																widget.onSubmit(_userAnswer);
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

	  for (int i = 0; i < (widget.info.length/2).ceil() + 1; i += 2) {
		  rows.add(
				  Row(
					  mainAxisAlignment: (i + 1 < widget.info.length) ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
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
											  return 'Please enter this dog\'s ${widget.info[i]}';
										  }
									  },

									  onChanged: (text) {
									  	print(text);
									  },

									  onSaved: (val) {
									  	if (widget.info[i] == 'name') {
									  		_userAnswer.setName(val);
										  } else {
									  		_userAnswer.details[widget.info[i]] = val;
										  }
									  }
							  ),
						  ),
						  (i + 1 < widget.info.length) ?
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
												  return 'Please enter this dog\'s ${widget.info[i + 1]}';
											  }
										  },

										  onChanged: (text) { // for debug purposes :_(
											  print(text);
										  },

										  onSaved: (val) {
										  	if (widget.info[i+1] == 'name') {
												  _userAnswer.setName(val);
											  } else {
												  _userAnswer.details[widget.info[i + 1]] = val;
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
  	return widget.info[index][0].toUpperCase() + widget.info[index].substring(1);
  }


}