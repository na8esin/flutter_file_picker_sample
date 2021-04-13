import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final ImagePicker _picker = ImagePicker();
          _picker.getImage(source: ImageSource.gallery);
        },
        child: Text('pick!'),
      ),
    );
  }
}
