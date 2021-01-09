import 'package:flutter/material.dart';
import 'package:quiqui/Dog.dart';

class AnswerView extends StatelessWidget {
  final Dog dog;
  final double dimension = 305.0;

  AnswerView(this.dog);

  Widget getDetails(Map<String, dynamic> details) {
    List<Widget> textDetails = new List<Widget>();

    details.forEach((key, value) => {
          textDetails
              .add(Text('${key[0].toUpperCase()}${key.substring(1)}: $value'))
        });

    return new Column(children: textDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  width: dimension,
                  height: dimension,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue, width: 5.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Name: ${dog.getName}'),
                      getDetails(dog.details)
                    ],
                  ))
            ]));
  }
}
