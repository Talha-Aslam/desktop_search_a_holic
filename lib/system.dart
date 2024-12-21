// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class System {
  // Creating Files
  void createFilesAndFolders() async {
    // Creating A Folder in the Document Directory
    Directory directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    String path = directory.path;
    Directory folder = Directory('$path/SeachAHolic');

    // IF There is No Folder in the Document Directory
    if (!folder.existsSync()) {
      folder.create();
      print('Folder created at ${folder.path}');
    } else {
      print('Folder already exists at ${folder.path}');
    }

    // Creating a dummy file in the folder
    File file = File('${folder.path}/dummy.txt');
    if (!file.existsSync()) {
      file.writeAsStringSync('This is a dummy file.');
      print('File created at ${file.path}');
    } else {
      print('File already exists at ${file.path}');
    }
  }
}
