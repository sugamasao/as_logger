# com.github.sugamasao.as_logger.Logger Class

## Description

AS3製のログクラスです。
特徴は以下の通りです。

* Traceログとブラウザ上の console.log(無い場合は window.status) へ出力（出力先は変更可能）
* 渡されたオブジェクトはできるだけ展開し、文字列形式へ変形して出力します
* Logger.log メソッドを呼んだメソッド名やクラス名を出力します
* -compile.debug が true でコンパイルしている場合はソースファイル名や行数を出力することが可能です

以下に ASDoc があります。

* http://sugamasao.github.com/as_logger

## Synopsis

### use code

```as3
import com.github.sugamasao.as_logger.Logger

Logger.log({"hoge":this, "fuga":1});
Logger.log("MovieClip", new MovieClip());
```

### result(use -compile.debug)

```
[2010-1-27T0:6:35] LoggerDrive.as:33@LoggerDrive#initialize() {"fuga":1<int>,"hoge":root1<LoggerDrive>}<Object>
[2010-1-27T0:6:35] LoggerDrive.as:35@LoggerDrive#initialize() "MovieClip",instance1<flash.display::MovieClip>
```

### result(not use -compile.debug)

```
[2010-2-10T0:33:42] LoggerDrive#initialize() {"fuga":1<int>,"hoge":root1<LoggerDrive>}<Object>
[2010-2-10T0:33:42] LoggerDrive#initialize() "MovieClip",instance1<flash.display::MovieClip>
```

### [BETA]pp method

```as3
Logger.pp([1, 2]);
```

out puts.

```
className => Array
  inspect=>[1,2]
  length=>2
```

## options

### ログ出力の動作を変更することが可能です


```as3
//出力ログのパッケージ名の出力方法について
Logger.isFullPackage = true  // Logger.log実行クラスをフルパッケージで表示
Logger.isFullPackage = false // Logger.log実行クラスをクラス名のみを出力（デフォルト）

// debug フラグが有効な場合のファイルパスの出力方法について
Logger.isFullPath = true  // ファイル名をフルパスで表示
Logger.isFullPath = false // ファイル名のみを出力（デフォルト）

//ログの出力先について
Logger.writeTarget = Logger.WRITE_TARGET_FULL         // すべての出力先に出力します(デフォルト)
Logger.writeTarget = Logger.WRITE_TARGET_TRACE_ONLY   // trace にのみ出力します
Logger.writeTarget = Logger.WRITE_TARGET_CONSOLE_ONLY // JSの console.log なければ window.status に出力します
Logger.writeTarget = Logger.WRITE_TARGET_NOTHING      // ログを出力しません。整形処理もおこないませんので、パフォーマンスへの影響は最小になります
```

## Features/Problems

* ビルドや動作確認は MacOSX で確認しています。
* コンパイラは FlexSDK 3.4 でビルドしています。
* Firefox3.5 safari4.1 で動作を確認しています。

### IE での動作について

* IE8 の場合、開発者ツール（F12）でのウィンドウを出していないと console.log が有効になりません。
* IE7 の場合はセキュリティ設定を変更すれば、ステータスバーにログが出力されます。
* IE6 ステータスバーに出力されます

### How To Build swc

```sh
$ compc -source-path ./src -include-sources ./src/com/github/sugamasao -optimize -output ./bin/as_logger.swc
```

## CHANGE LOG

* v1.9.2 swc対応
* v1.9.1 issue close #9(toStringの実装)
* v1.9 ロジック上にべた書きしてあるリテラルをリファクタリング
* v1.8 issue 14 fixed
* v1.7 pp メソッドについて文言などを修正
* v1.6 fixed issue #12, #13, and beta pp method.
* v1.5 パッケージ名の出力方法を変更できるようにした（デフォルトは省略）
* v1.4 XML の出力を修正

## Copyright

* Author:: sugamasao <sugamasao@gmail.com>
* License:: MIT License
