import 'package:csv/csv.dart';

void main(List<String> args) {
  final res = const CsvToListConverter().convert('title,body\r\nタイトル,ボディ');
  print(res);
}
