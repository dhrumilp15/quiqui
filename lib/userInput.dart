import 'package:flutter/material.dart';
import 'dart:core';

import 'package:quiqui/Dog.dart';
import 'package:quiqui/quiz.dart';

typedef onSubmitCallback = void Function(Dog userAnswer);

class UserInput extends StatefulWidget {
  final List info;
  final Quiz quiz;
  final onSubmitCallback onSubmit;
  final GlobalKey formKey;

  UserInput({this.formKey, this.quiz, this.info, this.onSubmit});

  @override
  _UserInputState createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
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
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
      Form(
        key: widget.formKey,
        child: GridView.count(
          shrinkWrap: true,
          childAspectRatio: 3 / 2,
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          padding: const EdgeInsets.all(10.0),
          children: List.generate(widget.info.length, (index) {
            return TextFormField(
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: getLabelText(index),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter their ${widget.info[index]}';
                  }
                  return null;
                },
                onSaved: (val) {
                  if (widget.info[index] == 'name') {
                    _userAnswer.setName(val);
                  } else {
                    _userAnswer.details[widget.info[index]] = val;
                  }
                });
          }),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                minimumSize: Size(MediaQuery.of(context).size.width / 4, 50)),
            onPressed: () {
              FormState form = widget.formKey.currentState;

              if (form.validate()) {
                form.save();
                widget.onSubmit(_userAnswer);
              }
            },
            child: Text('Submit',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.teal,
                minimumSize: Size(MediaQuery.of(context).size.width / 4, 50)),
            onPressed: () {
              widget.onSubmit(null);
              FormState form = widget.formKey.currentState;
              form.reset();
            },
            child: Text('Don\'t Know',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ],
      )
    ]);
  }

  String getLabelText(int index) {
    return widget.info[index][0].toUpperCase() +
        widget.info[index].substring(1);
  }
}
