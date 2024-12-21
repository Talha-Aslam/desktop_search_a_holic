import 'package:flutter/material.dart';

class UploadData extends StatefulWidget {
  const UploadData({super.key});

  @override
  _UploadDataState createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  void _uploadDummyData() {
    // Dummy upload logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data uploaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                // Making the button in the center
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.all(100), // 100 is the width of the button
                child: ElevatedButton(
                  onPressed: _uploadDummyData,
                  child: const Text('Upload Data'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
