import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
	final String file;
	final double dimension = 305.0;
	ImageView(this.file);

	@override
	Widget build(BuildContext context) {
		return Container(
				padding: EdgeInsets.symmetric(vertical : 50.0),
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