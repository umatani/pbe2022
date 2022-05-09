# Emacsのracket-mode不具合の修正

Schemeコード中にある種の誤りがあると，Emacsの対話環境で実行中のRacket処理系が異常終了することが分かりました．これは，Emacs用のRacket開発環境であるracket-modeの不具合（バグ）です．

バグが修正されるのを待っていられませんので，正常に動作していた頃の古いバージョンを使うよう，Emacsの設定をやり直します．[第1回配布資料](../chap/01_intro.html)の手順どおりに**環境構築を済ませた後**で，以下の作業を行ってください．

1. `.emacs.d`ディレクトリの削除

```shell
$ cd
$ rm -rf .emacs.d/
```

2. Emacsを一度起動

```shell
$ runemacs
```

起動したらそのままEmacsを一旦終了．

3. 修正版の`init.el`を設置

[このリンクの`init.el`](racket-mode/init.el)をダウンロードして以下を実行．

```shell
$ cd
$ mv Downloads/init.el .emacs.d/
```

4. 正常な`racket-mode`の取得

[このリンクの`racket-mode-v2.zip`](racket-mode/racket-mode-v2.zip)をダウンロードして以下を実行．

もし第1回資料に書かれている `unzip` をまだインストールしていないなら，次を実行してインストール．

```shell
$ scoop install zip unzip
```

その後，以下を実行して `racket-mode-v2.zip` を適切な場所に展開．

```shell
$ cd
$ mkdir lib
$ cd lib
$ mv ../Downloads/racket-mode-v2.zip .
$ unzip racket-mode-v2.zip
```

5. 動作確認

```shell
$ runemacs
```

でEmacsを起動．第1回資料と同じようにしばらく待ってパッケージのインストールが完了したら，またEmacsを終了．

もう一度，

```shell
$ runemacs
```

で Emacs を起動し，`sample.rkt`ファイルを開いて以下のようなプログラムを書き，`C-c C-k`で実行．

```racket
#lang racket

(define a 1)
(define (inc x) (+ x b))
```

異常終了せず，次のようなエラーが表示されるだけであればOK．

```racket
; /Users/umatani/sample.rkt:4:21: b: unbound identifier
;   in: b
```
