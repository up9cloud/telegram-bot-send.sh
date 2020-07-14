# telegram-bot-send.sh

A telegram bot cli, only handle send methods, for notify things.

Works with [busybox](https://www.busybox.net/).

## Usage

```sh
TELEGRAM_BOT_TOKEN=<bot token>
TELEGRAM_CHAT_ID=<chat id>
./tg.ash -h
```

```sh
docker run --rm \
  -e TELEGRAM_BOT_TOKEN=<bot token> \
  -e TELEGRAM_CHAT_ID=<chat id>
  sstc/telegram-bot-send.sh \
  --help
```

## TODO

- [sendMediaGroup](https://core.telegram.org/bots/api#sendmediagroup)
