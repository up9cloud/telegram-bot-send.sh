# telegram-bot-send.sh

A telegram bot cli, only handle send* methods, for notification purpose.

Dependencies:

- [busybox](https://busybox.net/downloads/BusyBox.html)
  - [ash]
  - [cat]
  - [getopt]
- curl
- jq

## Installation

```console
~$ docker run --rm -it alpine /bin/sh
/ # apk add --no-cache curl jq
/ # curl https://raw.githubusercontent.com/up9cloud/telegram-bot-send.sh/master/tg.ash -O /usr/local/bin/tg
/ # chmod +x /usr/local/bin/tg
/ # tg -h
```

## Usage

```sh
tg -h
```

```sh
TELEGRAM_BOT_TOKEN=<bot token>
TELEGRAM_CHAT_ID=<chat id>
tg -m "hello world"
```

## TODO

- [sendMediaGroup](https://core.telegram.org/bots/api#sendmediagroup)
