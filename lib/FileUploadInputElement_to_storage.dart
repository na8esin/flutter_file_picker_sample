import 'dart:html' as html;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'credential.dart';

Future<void> main() async {
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.signInWithCredential(
        EmailAuthProvider.credential(email: email, password: password));
  } on Exception catch (e) {
    print('$e');
  }

  runApp(UploadApp());
}

class UploadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
/// から結構修正
///
class FileUploadApp extends StatefulWidget {
  @override
  createState() => _FileUploadAppState();
}

class _FileUploadAppState extends State {
  GlobalKey _formKey = GlobalKey();
  html.File? _file;

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
      _file = files![0];
    });
  }

  Future makeRequest() async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final uploadTask = storage.ref().child('test.csv').putBlob(_file);
    uploadTask.snapshotEvents.listen((event) {}, onError: (e) => print(e));
    await uploadTask;
  }
}
