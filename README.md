# flutter_file_picker_sample

A new Flutter project.

## Getting Started

binフォルダにおけばブラウザが立ち上がらない

## データの取扱考察
- firestoreに直接入れたほうがいいのか？functionsに渡すのか？
- functionsはメモリ制限が4G
- firestoreは1G超えると有料になる
- そもそもデータが全部揃った状態じゃないと処理できない
- Storageは5Gまで無料
- Storageに直接アップロードできるにしても、簡易チェックはしたいから、
  - flutter上でデータが見れる必要がある
- 簡易チェック
  -   列数があってない
  -   拡張子：これはアップロードするときにできる
  -   必須項目が空
