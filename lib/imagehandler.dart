import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import 'package:archive/archive.dart';
import 'dart:async';

class ImageHandler {
	Map<String, dynamic> json;

	final String urlPath;
	final String zipName;
	String regularName;

	bool downloading = false;
	String progress;


	ImageHandler({this.urlPath = "https://api.github.com/repos/dhrumilp15/quiqui_imgs/contents/", this.zipName}) {
		if (urlPath == null) {
			this.json = jsonDefault;
		}
	}

	Future<String> get loadPath async {
		Directory saveDir = null;

		saveDir = await getApplicationDocumentsDirectory();

		return saveDir.path;
	}

	Future<void> _createDirectory(path) async {
		final Directory directory = await Directory('$path/CapturedImages').create(recursive: true);
		print("The directory $directory is created");
	}

	void listD(Directory dir) async {
		Stream<FileSystemEntity> entityList = dir.list(recursive: true, followLinks: false);
		await for (FileSystemEntity entity in entityList) print(entity.path);
	}

	Future<void> downloadImages() async {
		final path = await loadPath;
		print('path: $path');

		if (!await Directory(path).exists()) {
			_createDirectory(path);
		} else {
			print("THE APPLICATION DOCUMENTS DIRECTORY EXISTS");
			listD(Directory(path));
		}

		Map<String, dynamic> downloadJson = await _fetchDownloadUrl(this.urlPath, this.zipName);

		String downloadUrl = downloadJson["download_url"];

		String name = downloadJson["name"];

		await _download(downloadUrl, path, name);

		await unzip(path, name);

		print("ALL DONE DOWNLOADING");
		return;
	}

	Future<Map<String, dynamic>> _fetchDownloadUrl(String url, String name) async {
		final response = await http.get(url);

		if (response.statusCode == 200) {
			List<dynamic> githubJson = jsonDecode(response.body);

			Map<String, dynamic> specificJson = _findJson(githubJson, name);
			return specificJson;
		} else {
			throw Exception("UNLUCKY - Github call for Download URL failed!");
		}
	}


	Future<void> _download(String githubUrl, String saveDirPath, String nameOfZip) async {
		Dio dio = new Dio();
		print("downlaodUrl: $githubUrl");
		print("saveDirPath: $saveDirPath");


		await dio.download(githubUrl, "$saveDirPath/$nameOfZip",
		onReceiveProgress: (rec, total) {
			print("downloading");
			downloading = true;
			progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
		});

		return;
	}

	Future<void> unzip(String path, String zipName) async {
		print("ENTERED THE UNZIP");
		final bytes = File("$path/$zipName").readAsBytesSync();
		
		String saveDirName = "$path/${zipName.substring(0, zipName.lastIndexOf('.zip'))}"; // Ex - dogs.zip, this will produce a dog/ folder for all the images
//		String saveDirName = path;
		// Decode the Zip file
		final archive = ZipDecoder().decodeBytes(bytes);


		// Extract the contents of the Zip archive to disk.
		for (final file in archive) {
			final filename = file.name;
			print('filename: $filename');
			if (file.isFile) {
					final data = file.content as List<int>;
					print('Saved Location: $saveDirName/$filename');
					File('$saveDirName/' + filename)
						..createSync(recursive: true)
						..writeAsBytesSync(data);
					if (file.name == "images.json") {
						this.json = await parseJson(File('$saveDirName/' + filename));
						this.json[zipName.substring(0, zipName.lastIndexOf('.zip'))].forEach((dog) => {
							dog["filepath"] = "$path/${zipName.substring(0, zipName.lastIndexOf('.zip'))}/${dog["filepath"]}"
						});
					}
			} else {
				Directory('$saveDirName/' + filename)
					..create(recursive: true);
			}
		}
		return;
	}

	Future<Map<String, dynamic>> parseJson(File file) async {
		String contents = await file.readAsString();

		return jsonDecode(contents)[0] as Map<String, dynamic>;
	}

	Map<String, dynamic> _findJson(List<dynamic> githubJson, String name) {
		for (int i = 0; i < githubJson.length; i++) {
			Map<String, dynamic> json = githubJson[i];
			if (json["name"] == name) {
				return json;
			}
		}

		throw Exception("That doesn\'t exist!");
	}

	Map<String, dynamic> getJson() {
		return this.json;
	}

	List<String> getInfo() {
		return json['info'];
	}

	Map<String, dynamic> get defaultJson {
		return this.jsonDefault;
	}

	final Map<String, dynamic> jsonDefault =
	{
		"info" : ["name", "owner", "origin"],
		"dogs" : [
			{
				"name" : "Toto",
				"filepath" : "lib/assets/images/toto.jpg",
				"owner" : "Dorothy",
				"origin" : "The Wizard of Oz"
			},
			{
				"name" : "Laika",
				"filepath" : "lib/assets/images/laika.jpg",
				"owner" : "Russian Space Agency",
				"origin" : "Russia's first space mission"
			},
			{
				"name" : "Lassie",
				"filepath" : "lib/assets/images/lassie.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Scooby Doo",
				"filepath" : "lib/assets/images/scooby.jpg",
				"owner" : "He\'s a free dog",
				"origin" : "The Scooby Doo show"
			},
			{
				"name" : "Balto",
				"filepath" : "lib/assets/images/balto.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Bo",
				"filepath" : "lib/assets/images/Bo.jpg",
				"owner" : "The Obamas",
				"origin" : "Real Life"
			},
			{
				"name" : "Sunny",
				"filepath" : "lib/assets/images/sunny.jpg",
				"owner" : "The Obamas",
				"origin" : "Real Life"
			},
			{
				"name" : "Higgins",
				"filepath" : "lib/assets/images/higgins.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Doug",
				"filepath" : "lib/assets/images/doug.jpg",
				"owner" : "igHandle",
				"origin" : "Instagram"
			},
			{
				"name" : "Wishbone",
				"filepath" : "lib/assets/images/wishbone.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Rin Tin Tin",
				"filepath" : "lib/assets/images/rintintin.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Old Yeller",
				"filepath" : "lib/assets/images/oldyeller.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Sinbad",
				"filepath" : "lib/assets/images/sinbad.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Trakr",
				"filepath" : "lib/assets/images/trakr.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Bobbie",
				"filepath" : "lib/assets/images/bobbie.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Jofi",
				"filepath" : "lib/assets/images/jofi.jpg",
				"owner" : "Sigmund Freud",
				"origin" : "Real Life"
			},
			{
				"name" : "Koko",
				"filepath" : "lib/assets/images/koko.jpeg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Snowy",
				"filepath" : "lib/assets/images/snowy.jpg",
				"owner" : "Tin Tin",
				"origin" : "Tin Tin"
			},
			{
				"name" : "Spot",
				"filepath" : "lib/assets/images/spot.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			},
			{
				"name" : "Milie",
				"filepath" : "lib/assets/images/milie.jpg",
				"owner" : "UNKNOWN",
				"origin" : "UNKNOWN"
			}
		],
	};
}