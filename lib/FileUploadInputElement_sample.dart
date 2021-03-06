import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

void main() => runApp(UploadApp());

class UploadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        primarySwatch: Colors.purple,
      ),
      home: FileUploadApp(),
    );
  }
}

/// https://rodolfohernan20.blogspot.com/2019/12/upload-files-to-server-with-flutter-web.html

class FileUploadApp extends StatefulWidget {
  @override
  createState() => _FileUploadAppState();
}

class _FileUploadAppState extends State {
  List<int>? _selectedFile;
  Uint8List? _bytesData;
  GlobalKey _formKey = GlobalKey();
  String? _path;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('A Flutter Web file picker'),
        ),
        body: Container(
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 28),
              child: Container(
                  width: 350,
                  child: Column(children: [
                    MaterialButton(
                      color: Colors.pink,
                      elevation: 8,
                      highlightElevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      textColor: Colors.white,
                      child: Text('Select a file'),
                      onPressed: () {
                        startWebFilePicker();
                      },
                    ),
                    Divider(
                      color: Colors.teal,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        makeRequest();
                      },
                      child: Text('Send file to server'),
                    ),
                  ])),
            ),
          ),
        ),
      ),
    );
  }

  startWebFilePicker() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    // https://stackoverflow.com/questions/57544325/how-to-upload-a-specific-type-of-file-with-fileuploadinputelement-in-flutter-for
    uploadInput.accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files![0];
      _path = file.relativePath;
      // ??????????????????
      print('file.relativePath ${file.relativePath}');
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        if (reader.result == null) {
          print('reader.result is null');
        }

        _handleResult(reader.result!);
      });
      reader.readAsDataUrl(file);
    });
  }

  void _handleResult(Object result) {
    setState(() {
      // data:text/csv;base64,dGl0bGUsYm9keQrjgr/jgqTjg4jjg6ss44Oc44OH44KjCgo=
      // print(result.toString());
      final encoded = result.toString().split(",").last;
      String decoded = utf8.decode(base64.decode(encoded));
      print(decoded);
      _bytesData = Base64Decoder().convert(encoded);

      // ?????????????????????????????????
      _selectedFile = _bytesData;
    });
  }

  Future makeRequest() async {
    print('_path $_path');
  }
}
