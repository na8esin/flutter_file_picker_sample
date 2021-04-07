import 'package:csv/csv.dart';

void main(List<String> args) {
  // 各行の列数が違ってもエラーが発生しない
  final res = const CsvToListConverter().convert('title,body\r\nタイトル,ボディ,フッター');
  print(res);
  print(const CsvToListConverter().convert("title,body\r\nタイトル,"));
}
