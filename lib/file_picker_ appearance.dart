import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';

/// file_pickerが勝手に生成するタグを非表示にする

Future<void> main() async {
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyApp(),
  )));
}

makeInvisible() {
  final target = querySelector('#__file_picker_web-file-input');
  target!.setAttribute('style', 'display:none');
}

Future<PlatformFile?> chooseFileUsingFilePicker() async {
  final result = await FilePicker.platform.pickFiles(
    allowedExtensions: ['csv'],
    type: FileType.custom,
    withReadStream: true,
  );
  makeInvisible();
  if (result != null) {
    return result.files.single;
  } else {
    print('result is $result');
  }
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
      onPressed: () async {
        await chooseFileUsingFilePicker();
      },
      child: Text('choose'),
    ));
  }
}
