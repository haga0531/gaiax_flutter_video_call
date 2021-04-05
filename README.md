# gaiax_flutter_video_call

## XD

https://xd.adobe.com/view/9313e157-968e-4fdb-8a39-2691428460a1-c640/

## agora の console

- https://console.agora.io/
- ここでプロジェクトを作成し、App ID と,Token を作る.
  - Token 作成時に channel 名も入力しており、main.dart に埋め込んである

## 使用プラグイン

- https://pub.dev/packages/agora_rtc_engine

## 備考

- 現在.env に入っている token は一時的なもので発行から 1 日で切れるため都度作成する
- ドキュメントは英語、中国語

## 参考資料

- https://docs.agora.io/en/Video/start_call_flutter?platform=Flutter
- [Qiita](https://qiita.com/v-cube)もある

## agora を既存プロジェクトに導入するために

### 結論

- token をサーバーで作ってそれを client に渡せば ok
  - ex DM
  - 1vs1 の組み合わせが無数にある
    - 全員が同じ channelName だと同じ部屋になるからよくない
    - チャンネルネームのインプットはいらない？
      - 裏側で token を自動生成してビデオチャットを開始する
      - node などで server を立てればいけそう

### 必要なもの

- console 画面から取得できる
  - appId
  - appCertificate
- サーバー側で Token を作る時に必要なもの
  - 上記二つ + channelName, uid, expiredTime
  - これらを引数に入れて関数を実行すると token が返るのでそれを client 側に持っていって使用する
- client 側で生成して上記サーバーに渡すようにした方が良い場合もあるもも
  - channelName
    - 1 : 1 ならサーバー側でも良いと思うが(すでに相手ユーザーがわかっているためチャンネル名の指定とかいらないから)、 n : 1 or n : n なら必要かも。
    - ぶっちゃけサーバー生成で良いと思う。channelName を自分で作ってそれが部屋タイトルになるよりは、別で Title とかを持っておいた方が配信中の変更とかもできて都合が良さそう。
