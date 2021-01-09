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
  final String repoLocation =
      "https://api.github.com/repos/dhrumilp15/quiqui-imgs/contents/";
  String path;

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
    this.path = (await loadPath).path;
    var response;
    try {
      response = await http.get(url);
    } catch (stacktrace) {
      print(stacktrace);
    }
    List<String> zips = [];

    if (response?.statusCode == 200) {
      List<dynamic> githubJson = jsonDecode(response.body);

      githubJson.forEach((json) {
        if (json["name"].endsWith('.zip')) {
          zips.add(json["name"]);
        }
      });
    }

    List<String> existingZip = await existingZips(zips);
    existingZip.forEach((zipName) {
      if (zips.contains("$zipName.zip")) {
        zips[zips.indexOf("$zipName.zip")] = zipName;
      }
    });

    return zips;
  }

  Future<List<String>> existingZips(List<String> repoZips) async {
    List<String> zips = new List<String>();

    Stream<FileSystemEntity> entityList =
        (await loadPath).list(recursive: false, followLinks: false);
    await for (FileSystemEntity entity in entityList) {
      if (entity is Directory &&
          repoZips.contains(
              "${entity.path.substring(entity.path.lastIndexOf("/") + 1)}.zip")) {
        if (FileSystemEntity.typeSync("${entity.path}/images.json") !=
            FileSystemEntityType.notFound) {
          var finalPath = entity.path.substring(entity.path.lastIndexOf('/') +
              1); //To account for the "/" in file paths
          zips.add(finalPath);
        }
      }
    }
    return zips;
  }

  Future<Directory> get loadPath async {
    return await getApplicationDocumentsDirectory();
  }

  void onLoading(BuildContext context, String zipName) async {
    this.imageHandler = ImageHandler(zipName: zipName);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                CircularProgressIndicator(),
                Text("Loading Package...")
              ]));
        });

    String zips = zipName;

    if (!zipName.endsWith('.zip')) {
      await this.imageHandler.loadFromAppDocs();
    } else {
      await this.imageHandler.downloadImages();
      zips = zipName.substring(0, zipName.indexOf('.zip'));
    }

    var json = this.imageHandler.getJson();

    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, MyHomePage.routeName,
        arguments: RouteArgs(json, zips, path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Qui Qui - Learn Faster With Flashcards')),
        body: FutureBuilder<List<String>>(
            future: zips,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height / 2),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("Features:",
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(fontSizeFactor: 2.0)),
                                ListView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(8),
                                  children: <Widget>[
                                    ListTile(
                                        leading: Icon(Icons.bookmark_rounded),
                                        title: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: 'Packetization: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20)),
                                              TextSpan(
                                                  text:
                                                      'Decks of images are stored in a github repo',
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                            ],
                                          ),
                                        )),
                                    ListTile(
                                        leading: Icon(Icons.casino_rounded),
                                        title: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: 'Shuffling: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20)),
                                              TextSpan(
                                                  text:
                                                      'The order of cards is randomly selected',
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                            ],
                                          ),
                                        )),
                                    ListTile(
                                        leading: Icon(Icons.palette),
                                        title: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: 'Customization: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20)),
                                              TextSpan(
                                                  text:
                                                      'Choose what to learn with the fields in each deck!',
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                                Text("Choose a deck of images:",
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(fontSizeFactor: 2.0)),
                              ])),
                      Divider(),
                      ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return ExpansionTile(
                                title: Text(capitalize(snapshot.data[index]),
                                    style: TextStyle(fontSize: 20)),
                                children: <Widget>[
                                  RaisedButton(
                                      child: Text("Use this package?",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        onLoading(
                                            context, snapshot.data[index]);
                                      },
                                      color: Colors.blue)
                                ]);
                          },
                          itemCount: snapshot.data.length)
                    ]);
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
              ));
            }));
  }
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
