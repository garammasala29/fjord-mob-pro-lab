# rurema_opener
irbで`rurema(:String)`のように呼び出すと指定したクラスのるりまのページをブラウザで開くよ。

## usage
```bash
$ irb
  require_relative 'rurema'
  rurema(:String)
```

## tips
* `require_relative 'rurema'`が面倒くさい場合、.irbrcに`require_relative 'rurema'`と書くといいよ。
* wsl環境で、windowsのchromeを使いたい場合、shのコンフィグファイル(.bashrcなど)に`export BROWSER="/mnt/c/'Program Files'/Google/Chrome/Application/chrome.exe"`って感じで、環境変数BROWSERにchromeのパスを書くといいよ。
* wsl(ubuntu)でしか動作確認してないよ。
