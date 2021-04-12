import 'dart:io';
import 'dart:typed_data';

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

/// file_pickerを使って、firebase_storageにアップロードする
/// functionsのキックはアップロードを待つか？
/// キックすること自体を非同期にするとスケジューラが必要になりそう
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
    final result = await FilePicker.platform.pickFiles(
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
      // webだとサポートしてないのか
      // https://github.com/miguelpruivo/flutter_file_picker/blob/master/lib/src/file_picker_result.dart#L22
      // でもこの例外はどうやって発生するんだ？
      print('objFile.path = ${objFile.path}');
      //return;
    }

    // withData: true,にしないといけない
    //print('bytes = ${objFile.bytes!}');
    //final bytes = objFile.bytes!;

    // readStreamが使えると大きなファイルが効率的に処理できそう
    // withData: trueでも変わらない実装になりそうだが、
    // pluginに関数が増えた時のために頑張る
    //
    // でもこれ、intだと列数チェックとかできなくない？
    final elements =
        await objFile.readStream!.fold<List<int>>([], (previous, element) {
      previous.addAll(element);
      return previous;
    });
    final ref = storage.ref();
    // ファイルの上書きとかが気になる
    final csvRef = ref.child(objFile.name!);
    await putDataOrString(csvRef, Uint8List.fromList(elements));
  }

  /// 現実的な選択肢だとputDataかputString
  /// Stringはあまり効率的なデータではなさそう
  Future<void> putDataOrString(
      firebase_storage.Reference csvRef, Uint8List bytes) async {
    final uploadTask = csvRef.putData(bytes);

    uploadTask.snapshotEvents.listen((event) {}, onError: (e) {
      print('some error');
    });
    await uploadTask;
  }

  void putBlob() {
    // web only。FileUploadInputElementと一緒に使える
    // final uploadTask = csvRef.putBlob(objFile);
  }

  void putFile(objFile, csvRef) {
    // webだと pathは取れないけど、nameがいけるんじゃないか？ -> 無理
    print('objFile.name= ${objFile.name}');
    File ioFile = File(objFile.name!);
    // Error: Unsupported operation: Platform._operatingSystem
    final uploadTask = csvRef.putFile(ioFile);
  }
}
