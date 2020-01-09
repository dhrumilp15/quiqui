import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:quiqui/imagehandler.dart';
import 'package:quiqui/main.dart';
import 'package:quiqui/MyHomePage.dart';

class LandingPage extends StatefulWidget {
	static const routeName = '/';

	@override
	_LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
	final String repoLocation = "https://api.github.com/repos/dhrumilp15/quiqui_imgs/contents/";

	Future<List<String>> zips;
	ImageHandler imageHandler;

	@override
	void initState() {
		super.initState();
		zips = _fetchZips(repoLocation);
	}

	@override
	void dispose() {
		super.dispose();
	}

	Future<List<String>> _fetchZips(String url) async {
		final response = await http.get(url);
		List<String> zips = [];

		if (response.statusCode == 200) {
			List<dynamic> githubJson = jsonDecode(response.body);


			githubJson.forEach((json) {
				if (json["name"].endsWith('.zip')) {
					zips.add(json["name"]);
				}
			});
		} else {
			throw Exception("Oh No! - Github call for Download URL failed!");
		}

		List<String> existingZip = await existingZips();
		print('existingZip: $existingZip');

		print(zips);

		existingZip.forEach((zipName) {
			print(zips);
			if (zips.contains("$zipName.zip")) {
				zips[zips.indexOf("$zipName.zip")] = zipName;
			}
		});
		print(zips);

		return zips;
	}

	Future<List<String>> existingZips() async {
		List<String> zips = new List<String>();

		Stream<FileSystemEntity> entityList = (await loadPath).list(recursive: false, followLinks: false);
		await for (FileSystemEntity entity in entityList) {
			if (entity is Directory && entity.path.substring(entity.path.lastIndexOf('/')) != "/flutter_assets") {
				var finalPath = entity.path.substring(entity.path.lastIndexOf('/') + 1);  //To account for the "/" in file paths
				zips.add(finalPath);
			}
		}

		return zips;
	}

	Future<Directory> get loadPath async {
		var saveDir = await getApplicationDocumentsDirectory();

		return saveDir;
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
							Text("Loading Package...")
						]
					)
				);
			}
		);

		if (!zipName.endsWith('.zip')) {
			await this.imageHandler.loadFromAppDocs();
		} else {
			await this.imageHandler.downloadImages();
		}

		var json = this.imageHandler.getJson();

		Navigator.pop(context);
		Navigator.pushReplacementNamed(
			context,
			MyHomePage.routeName,
			arguments: RouteArgs(
					json
			)
		);
	}
	
	String capitalize(String zip) {
		var finalZip = zip[0].toUpperCase();
		if (zip.contains('.zip')) {
			finalZip += zip.substring(1, zip.lastIndexOf('.zip'));
		} else {
			finalZip += zip.substring(1);
		}
		return finalZip;
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
							print(snapshot);
							return Center(
								child: SingleChildScrollView(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											mainAxisSize: MainAxisSize.min,
											children: <Widget>[
												Text("PEPSI MAN"),
												Flexible(
													fit: FlexFit.loose,
													child: ListView.builder(
														shrinkWrap: true,
															itemBuilder: (BuildContext context, int index) {
															print(index);
															return ExpansionTile(
																		title: Text(capitalize(snapshot.data[index])),
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
