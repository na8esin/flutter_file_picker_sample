import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'credential.dart';

final storageProvider =
    Provider((ref) => firebase_storage.FirebaseStorage.instance);

Future<void> main(List<String> args) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.signInWithCredential(
        EmailAuthProvider.credential(email: email, password: password));
  } on Exception catch (e) {
    print('$e');
  }
  // そもそもrelease modeにするのが難しい
  // if (kDebugMode) print('debug!');
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyApp(),
  )));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<PlatformFile?> objFileController = useState(null);
    PlatformFile? objFile = objFileController.value;
    final firebase_storage.FirebaseStorage storage =
        useProvider(storageProvider);

    return Container(
      child: Column(
        children: [
          //------Button to choose file using file picker plugin
          ElevatedButton(
              child: Text("Choose File"),
              onPressed: () async {
                objFile = await chooseFileUsingFilePicker();
              }),
          //------Show file name when file is selected
          if (objFile != null) Text("File name : ${objFile!.name}"),
          //------Show file size when file is selected
          if (objFile != null) Text("File size : ${objFile!.size} bytes"),
          //------Show upload utton when file is selected
          ElevatedButton(
              child: Text("Upload"),
              onPressed: () => uploadSelectedFile(objFile, storage)),
        ],
      ),
    );
  }

  Future<PlatformFile?> chooseFileUsingFilePicker() async {
    var result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
      //withData: true,
      // this will return PlatformFile object with read stream
      // streamがtrueだと優先になる
      withReadStream: true,
    );
    if (result != null) {
      return result.files.single;
    } else {
      print('result is $result');
    }
  }

  // cloud storageに入れる
  void uploadSelectedFile(
      PlatformFile? objFile, firebase_storage.FirebaseStorage storage) async {
    if (objFile == null) {
      print('uploadSelectedFile: objFile is null');
      return;
    }
    if (objFile.path == null) {
      // webだとサポートしてないのかよ
      // https://github.com/miguelpruivo/flutter_file_picker/blob/master/lib/src/file_picker_result.dart#L22
      // でもこの例外はどうやって発生するんだ？
      print('objFile.path = ${objFile.path}');
      return;
    }

    final bytes = objFile.bytes!;
    // これが使えると大きなファイルが効率的に処理できそう
    // objFile.readStream;
    final ref = storage.ref();
    final csvRef = ref.child('sample.csv');
    // flutter webだとできないかもしれない
    //final uploadTask = csvRef.putFile(File());
    final uploadTask = csvRef.putData(bytes);
    // web onlyみたいだけど、使い方がわからん
    //csvRef.putBlob()
    uploadTask.snapshotEvents.listen((event) {}, onError: (e) => print(e));
    await uploadTask;
  }
}
