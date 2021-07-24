import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:edge_detection/edge_detection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imagePath;
  String apiLink="https://sbconstruction.org.in/sb/images/";

  Dio dio = Dio();
  Response? remoteResponse;

  @override
  void initState() {
    super.initState();
  }

  Future uploadScannedImg(String path) async {
    String fileName = path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
    });
    remoteResponse = await dio.post(
      apiLink,
      data: formData,
    );
    print(remoteResponse?.data);
  }

  Future<void> getImage() async {
    String? imagePath;
    try {
      imagePath = (await EdgeDetection.detectEdge);


      print("$imagePath");

    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }

    if (!mounted) return;

    setState(() {
      _imagePath = imagePath;
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:  Text("Scanner"),
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
                  onPressed:(){
                    getImage();
                    uploadScannedImg(_imagePath!);
                    },
                  child: Text('Scan'),
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

