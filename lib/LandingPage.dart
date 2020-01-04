import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quiqui/imagehandler.dart';
import 'package:quiqui/main.dart';

class LandingPage extends StatefulWidget {
	static const routeName = '/';

	@override
	_LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
	Future<List<String>> zips;
	ImageHandler imageHandler;

	@override
	void initState() {
		super.initState();
		zips = _fetchZips("https://api.github.com/repos/dhrumilp15/quiqui_imgs/contents/");

	}

	@override
	void dispose() {
		super.dispose();
	}

	Future<List<String>> _fetchZips(String url) async {
		final response = await http.get(url);

		if (response.statusCode == 200) {
			List<dynamic> githubJson = jsonDecode(response.body);
			List<String> zips = [];

			githubJson.forEach((json) {
				if (json["name"].endsWith('.zip')) {
					zips.add(json["name"]);
				}
			});
			return zips;
		} else {
			throw Exception("UNLUCKY - Github call for Download URL failed!");
		}
	}

	void onLoading(BuildContext context, String zipName) async {
		this.imageHandler = ImageHandler(zipName: zipName);
		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) {
				return Dialog(
					child: Row(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							CircularProgressIndicator(),
							Text("Downloading Package...")
						]
					)
				);
			}
		);

		await this.imageHandler.downloadImages();
		Navigator.pop(context);

		var sickoMode = this.imageHandler.getJson(); //sickoMode is the JSON

		Navigator.pushReplacementNamed(
			context,
			MyHomePage.routeName,
			arguments: Args(
					sickoMode
			)
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Qui Qui')
			),
			body: FutureBuilder<List<String>>(
					future: zips,
					builder: (context, snapshot) {
						if (snapshot.hasData) {
							return Center(
								child: SingleChildScrollView(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											mainAxisSize: MainAxisSize.min,
											children: <Widget>[
												Text("PEPSI MAN"),
//												Padding(
//														padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//														child: new TextField(
//															decoration: new InputDecoration(
//																	hintText: "Type in here!"
//															),
//														)
//												),
												Flexible(
													fit: FlexFit.loose,
													child: ListView.builder(
														shrinkWrap: true,
															itemBuilder: (BuildContext context, int index) {
//															return Text("Sicko mode");
																return ExpansionTile(
																		title: Text(snapshot.data[index].substring(0, snapshot.data[index].lastIndexOf('.zip'))[0].toUpperCase() +
																				snapshot.data[index].substring(0, snapshot.data[index].lastIndexOf('.zip')).substring(1)),
																		children: <Widget>[
																			RaisedButton(
																					child: Text(
																							"Use this package?",
																							style: TextStyle(color: Colors.white)
																					),
																					onPressed: () {
																						onLoading(context, snapshot.data[index]);
																					},
																					color: Colors.blue
																			)
																		]
																);
															},
															itemCount: snapshot.data.length
													),
												)
											]
										),
								)
							);
						} else if (snapshot.hasError) {
							return Text("${snapshot.error}");
						}

						return Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: <Widget>[
									Text('Loading Available Question Packages'),
									CircularProgressIndicator()
								],
							)
						);
					}
				)
		);
	}
}
