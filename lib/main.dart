import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
// ignore: unused_import
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Mems_App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Uint8List _imageBytes;
  String _imageName;
  final picker = ImagePicker();
  CloudApi api;
  bool isUploaded = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/credentials.json').then((json) {
      api = CloudApi(json);
    });
  }

  void _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        print('path:' + pickedFile.path);
        _image = File(pickedFile.path);
        _imageBytes = _image.readAsBytesSync();
        _imageName = _image.path.split('/').last;
        isUploaded = false;
      } else {
        print('No Image Selected');
      }
    });
  }

  void _saveImage() async {
    setState(() {
      loading = true;
    });
    //TODO Upload to Google Cloud
    final response = await api.save(_imageName, _imageBytes);
    print(response.downloadLink);
    setState(() {
      loading = false;
      isUploaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _imageBytes == null
            ? Text('No Image selected.')
            : Stack(
                children: [
                  Image.memory(_imageBytes),
                  if (loading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  (isUploaded)
                      ? Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: _saveImage,
                            child: Text('Save to Cloud'),
                          ),
                        )
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Select Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
