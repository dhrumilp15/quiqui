import 'package:flutter/material.dart';
import 'dart:core';

import 'package:quiqui/countdownTimer.dart';
import 'package:quiqui/Dog.dart';
import 'package:quiqui/quiz.dart';
import 'package:quiqui/flipCard.dart';

typedef onSubmitCallback = void Function(Dog userAnswer);

class userInput extends StatefulWidget {
	final List info;
	final Quiz quiz;
	final onSubmitCallback onSubmit;
	final GlobalKey formKey;

	userInput({this.formKey, this.quiz, this.info, this.onSubmit});

	@override
  _userInputState createState() => _userInputState();
}

class _userInputState extends State<userInput> {

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
						key: widget.formKey,
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
															FormState form = widget.formKey.currentState;

															if (form.validate()) {
																form.save();
																widget.onSubmit(_userAnswer);
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
															FormState form = widget.formKey.currentState;
															form.reset();
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