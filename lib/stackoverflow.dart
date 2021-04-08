import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// https://stackoverflow.com/questions/56252856/how-to-pick-files-and-images-for-upload-with-flutter-web/65759028#65759028
/// を改良
///
/// firestoreに直接入れたほうがいいのか？functionsに渡すのか？
/// functionsはメモリ制限が4G
/// firestoreは1G超えると有料になる
/// そもそもデータが全部揃った状態じゃないと処理できない
/// Storageは5Gまで無料
/// Storageに直接アップロードできるにしても、簡易チェックはしたいから、
///   flutter上でデータが見れる必要がある
/// 簡易チェック
///   列数があってない
///   拡張子：これはアップロードするときにできる
///   必須項目が空
void main() => runApp(MaterialApp(
      home: FileUploadWithHttp(),
    ));

class FileUploadWithHttp extends StatefulWidget {
  @override
  _FileUploadWithHttpState createState() => _FileUploadWithHttpState();
}

class _FileUploadWithHttpState extends State<FileUploadWithHttp> {
  PlatformFile? objFile;

  void chooseFileUsingFilePicker() async {
    //-----pick file by file picker,

    var result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      withReadStream:
          true, // this will return PlatformFile object with read stream
    );
    if (result != null) {
      setState(() {
        objFile = result.files.single;
      });
    }
  }

  /// firestoreに直接入れるつもりだからとりあえずのコード
  void uploadSelectedFile() async {
    // 日本語が変換できない
    // lastでいいのか？
    final charCodes = await objFile!.readStream!
        .map((event) => String.fromCharCodes(event))
        .last;
    print(charCodes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          //------Button to choose file using file picker plugin
          ElevatedButton(
              child: Text("Choose File"),
              onPressed: () => chooseFileUsingFilePicker()),
          //------Show file name when file is selected
          if (objFile != null) Text("File name : ${objFile!.name}"),
          //------Show file size when file is selected
          if (objFile != null) Text("File size : ${objFile!.size} bytes"),
          //------Show upload utton when file is selected
          ElevatedButton(
              child: Text("Upload"), onPressed: () => uploadSelectedFile()),
        ],
      ),
    );
  }
}
