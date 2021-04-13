import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyApp(),
  )));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () async {
          await startWebFilePicker();
        },
        child: Text('file pick'),
      ),
    );
  }
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

    final reader = html.FileReader();

    reader.onLoadEnd.listen((e) {
      if (reader.result == null) {
        print('reader.result is null');
      }
    });
    reader.readAsDataUrl(file);
  });
}
