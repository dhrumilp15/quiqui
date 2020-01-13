import 'package:flutter/material.dart';
import 'dart:io';

class ImageView extends StatelessWidget {
	final String file;
	final double dimension = 305.0;
	static final String urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
	final match = RegExp(urlPattern, caseSensitive: false);
	ImageProvider image;
	final String zipName;
	final String path;

	ImageView(this.file, this.zipName, this.path) {
		var firstmatch = match.firstMatch(this.file);
		if (firstmatch != null) {
			image = NetworkImage(file);
		} else if (file.startsWith("lib")) {
			image = AssetImage(file);
		} else {
			image = FileImage(File("${this.path}/${this.zipName}/$file"));
		}
	}

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
											image: image,
											fit: BoxFit.fill,
										)
								),
							)
						]
				)
		);
	}
}