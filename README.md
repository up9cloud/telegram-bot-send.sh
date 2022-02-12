# telegram-bot-send.sh

Another telegram bot cli, handling send* methods, for notification purpose.

There is [telegram.sh](https://github.com/fabianonline/telegram.sh), but

- It doesn't support busybox
- It's GPL

That's why I made this

## Dependencies

- [busybox](https://busybox.net/downloads/BusyBox.html)
- curl
- jq

## Installation

```console
~$ docker run --rm -it alpine /bin/sh
/ # apk add --no-cache curl jq
/ # curl https://raw.githubusercontent.com/up9cloud/telegram-bot-send.sh/master/tg.ash -O /usr/local/bin/tg
/ # chmod +x /usr/local/bin/tg
/ # tg --version
```

## Usage

```sh
tg -h
```

```sh
TELEGRAM_BOT_TOKEN=<bot token>
TELEGRAM_CHAT_ID=<chat id>
tg "hello world"
```

## Dev memo

- Setup `./config/telegram.org/config.json`

  ```json
  {
    "token": "012345678:xxxxxxxxxx",
    "chat_id": "123456789"
  }
  ```

## TODO

- [sendMediaGroup](https://core.telegram.org/bots/api#sendmediagroup)
