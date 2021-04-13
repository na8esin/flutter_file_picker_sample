import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {
  await chooseFileUsingFilePicker();
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyApp(),
  )));
}

Future<PlatformFile?> chooseFileUsingFilePicker() async {
  final result = await FilePicker.platform.pickFiles(
    allowedExtensions: ['csv'],
    type: FileType.custom,
    withReadStream: true,
  );
  if (result != null) {
    return result.files.single;
  } else {
    print('result is $result');
  }
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
