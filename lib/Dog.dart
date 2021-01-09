//Dog.dart
class Dog {
  // The name and file fields are required as the most basic amount of information about the images
  String name;
  String file;
  Map<String, dynamic> details =
      new Map<String, dynamic>(); // any other information

  Dog({this.name, this.file, this.details});

  factory Dog.fromJson(Map<String, dynamic> json) {
    // This is to account for any sort of other data users add to the answer card
    var details = new Map<String, dynamic>();

    json.forEach((key, value) => {
          if (!(key == 'name' || key == 'filepath'))
            {details.putIfAbsent(key, () => value)}
        });

    return Dog(
      name: json['name'] as String,
      file: json['filepath'] as String,
      details: details,
    );
  }

  String get getName {
    return this.name;
  }

  String get getFile {
    return file;
  }

  String toString() {
    return "name: ${this.name}, file: ${this.file}, details: ${this.details.toString()}";
  }

  void setName(String name) {
    this.name = name;
  }

  Map<String, dynamic> get map {
    // Since map will primarily be used for comparison purposes, keep everything as lowercase

    var transform = details.map((key, value) {
      return MapEntry(key, value.toLowerCase());
    });

    return {"name": this.name.toLowerCase(), ...transform};
  }
}
