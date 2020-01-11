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
			print('zips: $zips');
		} else {
			throw Exception("Oh No! - Github call for Download URL failed!");
		}

		List<String> existingZip = await existingZips(zips);
		print(existingZip);
		existingZip.forEach((zipName) {
			if (zips.contains("$zipName.zip")) {
				zips[zips.indexOf("$zipName.zip")] = zipName;
			}
		});

		return zips;
	}

	Future<List<String>> existingZips(List<String> repoZips) async {
		List<String> zips = new List<String>();

		Stream<FileSystemEntity> entityList = (await loadPath).list(recursive: false, followLinks: false);
		await for (FileSystemEntity entity in entityList) {
			print(entity.path);
			if (entity is Directory && repoZips.contains("${entity.path.substring(entity.path.lastIndexOf("/") + 1)}.zip")) {
				if (FileSystemEntity.typeSync("${entity.path}/images.json") != FileSystemEntityType.notFound) {
					var finalPath = entity.path.substring(entity.path.lastIndexOf('/') + 1);  //To account for the "/" in file paths
					zips.add(finalPath);
				}
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
		print('zipName: $zipName');

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
							return Column(
											mainAxisAlignment: MainAxisAlignment.start,
											children: <Widget>[
												ConstrainedBox(
													constraints: BoxConstraints(
														maxHeight: MediaQuery.of(context).size.height/2
													),
													child: Column(
														mainAxisAlignment: MainAxisAlignment.spaceEvenly,
														crossAxisAlignment: CrossAxisAlignment.center,
														children: <Widget>[
															Text("Welcome to Dhrumil's epic Who is Who app!"),
															Text("Pick the package of questions and answers you'd like to test yourself with here!"),
														]
													)
												),
												Divider(),
												ListView.builder(
														shrinkWrap: true,
														itemBuilder: (BuildContext context, int index) {
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
												)
											]
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
