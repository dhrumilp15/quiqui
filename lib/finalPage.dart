import 'package:flutter/material.dart';
import 'package:quiqui/quiz.dart';

class FinalPage extends StatelessWidget {
	final Quiz quiz;
	final VoidCallback onRetry;

	FinalPage({
		@required this.quiz,
		this.onRetry
	});

	@override
	Widget build(BuildContext context) {
		return
			Column(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					children: [
						Text(
								'You got ${quiz.getScore} out of ${quiz.total} correct!',
								style: TextStyle(fontSize: 20.0)
						),
						ButtonTheme(
								child: ElevatedButton(
										child: Text(
												'Retry?',
												style: TextStyle(color: Colors.white)
										),
										onPressed: () => onRetry()
								)
						),
					]
//				)
			);
	}
}