import 'dart:core';
import 'dart:math';
import 'package:quiqui/Dog.dart';

class Quiz {
  List<Dog> dogs;
  int score = 0;
  int dogIndex = 0;
  List<Dog> seen;
  int total;
  final random = Random();

  Quiz(Map<String, dynamic> imageJson, String zipName) {
    this.dogs = shuffle(jsonHandler(imageJson, zipName));
	  this.seen = new List();
    this.total = this.dogs.length;
  }

  void correct() {
  	if (!(dogs.length > 0)) return;
    Dog imp = getDog(dogIndex);
    if (dogs.contains(imp) && !seen.contains(imp)) score++;
    dogs.remove(imp);
    dogIndex++;
  }

  void incorrect() {
    if (!(dogs.length > 0)) return;
    Dog imp = getDog(dogIndex);
    seen.add(imp);
    dogIndex++;
  }

  Dog getDog(int dogindex) {
    if (dogs.length > 0) {
    	this.dogIndex = dogindex % dogs.length;
    } else {
    	return null;
    }
    return dogs[this.dogIndex];
  }

  List shuffle(List items) {
	  for (var i = items.length - 1; i > 0; i--) {

		  var n = random.nextInt(i + 1);

		  var temp = items[i];
		  items[i] = items[n];
		  items[n] = temp;
	  }

	  return items;
  }

  int get getScore {
  	return this.score;
  }

  List<Dog> jsonHandler(Map<String, dynamic> json, String key) {
	  return json[key].map<Dog>((dogJson) => Dog.fromJson(dogJson)).toList();
  }

}
