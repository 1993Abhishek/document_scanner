import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image/image.dart';
import 'package:flutter/services.dart';
import 'package:edge_detection/edge_detection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imagePath;
  String apiLink = 'https://kosher.des.vidinitechnology.com/api/v1/image';

  Dio dio = Dio();
  Response? remoteResponse;

  @override
  void initState() {
    super.initState();
  }

  Future uploadScannedImg(String path) async {
    // String fileName = path.split('/').last;
    // print(fileName);
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(path, filename: 'ksa.jpg'),
    });
    print(formData);
    remoteResponse = await dio.post(
      apiLink,
      data: formData,
    );
    print(remoteResponse?.data);
  }

  Future<void> getImage() async {
    String? imagePath;
    try {
      imagePath = await EdgeDetection.detectEdge;
      print("$imagePath");
      print('Checking path:${imagePath!.split('.').first+'.jpg'}');
    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }

    if (!mounted) return;

    setState(() {
      _imagePath = imagePath;
    });
    if(imagePath!.isNotEmpty)
      {
        print('Image Path:$imagePath');
        // uploadScannedImg(imagePath);
        convertToJpg(path: imagePath,);

      }

  }
  convertToJpg({String path=''})
  {
    final image = decodeImage(File(path).readAsBytesSync())!;
    // final thumbnail = copyResize(image, width: 70,height: 70);
    File(path.split('.').first+'.jpg').writeAsBytesSync(encodeJpg(image));
    print(path.split('.').first+'.jpg');
    uploadScannedImg(path.split('.').first+'.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Scanner"),
          centerTitle: true,
        ),
        body: Container(
          height: 400,
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    getImage();

                  },
                  child: Text(
                    'Scan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Saved image path:'),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 0, right: 0),
                child: Text(
                  '$_imagePath\n',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
