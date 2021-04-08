import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'credential.dart';

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
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<PlatformFile?> objFileController = useState(null);
    PlatformFile? objFile = objFileController.value;
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
              onPressed: () => uploadSelectedFile(objFile)),
        ],
      ),
    );
  }

  Future<PlatformFile?> chooseFileUsingFilePicker() async {
    var result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      withReadStream:
          true, // this will return PlatformFile object with read stream
    );
    if (result != null) {
      return result.files.single;
    }
  }

  // cloud storageに入れる
  void uploadSelectedFile(objFile) async {
    // 日本語が変換できない
    // lastでいいのか？
    final charCodes = await objFile!.readStream!
        .map((event) => String.fromCharCodes(event))
        .last;
    print(charCodes);
  }
}
