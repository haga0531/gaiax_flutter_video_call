# gaiax_flutter_video_call

## agoraのconsole
- https://console.agora.io/
- ここでプロジェクトを作成し、App IDと,Tokenを作る.
  - Token作成時にchannel名も入力しており、main.dartに埋め込んである

## 使用プラグイン
- https://pub.dev/packages/agora_rtc_engine


## 備考
- 現在.envに入っているtokenは一時的なもので発行から1日で切れるため都度作成する
- ドキュメントは英語、中国語

## 参考資料
- https://docs.agora.io/en/Video/start_call_flutter?platform=Flutter
- [Qiita](https://qiita.com/v-cube)もある


## agoraを既存プロジェクトに導入するために
### 結論
- tokenをサーバーで作ってそれをclientに渡せばok
  - ex DM
  - 1vs1の組み合わせが無数にある
    - 全員が同じchannelNameだと同じ部屋になるからよくない
    - チャンネルネームのインプットはいらない？
      - 裏側でtokenを自動生成してビデオチャットを開始する
      - nodeなどでserverを立てればいけそう

### 必要なもの
- console画面から取得できる
  - appId
  - appCertificate
- サーバー側でTokenを作る時に必要なもの
  - 上記二つ + channelName, uid, expiredTime
  - これらを引数に入れて関数を実行するとtokenが返るのでそれをclient側に持っていって使用する
- client側で生成して上記サーバーに渡すようにした方が良い場合もあるもも
  - channelName
    - 1 : 1ならサーバー側でも良いと思うが(すでに相手ユーザーがわかっているためチャンネル名の指定とかいらないから)、 n : 1 or n : n なら必要かも。
    - ぶっちゃけサーバー生成で良いと思う。channelNameを自分で作ってそれが部屋タイトルになるよりは、別でTitleとかを持っておいた方が配信中の変更とかもできて都合が良さそう。

