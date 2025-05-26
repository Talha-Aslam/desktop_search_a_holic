// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class System {
  // Creating Files
  void createFilesAndFolders() async {
    try {
      // Check if we're running on web platform
      if (kIsWeb) {
        print('Running on web platform - file operations are limited');
        return;
      }

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
    } catch (e) {
      print('Error creating files and folders: $e');
      // Continue execution even if file creation fails
    }
  }
}
