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

### Test

`./run_test.sh` runs [test/cases.sh](test/cases.sh) in a plain alpine container and sends real messages, so it needs a bot and a group with topics enabled. Put them in `.config/telegram.org/config.json` (gitignored):

```json
{
  "token": "012345678:xxxxxxxxxx",
  "group_id": "-1234567890",
  "group_thread_ids": [1, 2, 3]
}
```

### Bump the version

- Increment the VERSION variable in the `tg.ash` file
- Commit, tag it `vx.x.x` (`git tag vx.x.x`), then `git push && git push --tags`
- The tag push creates the [GitHub release](https://github.com/up9cloud/telegram-bot-send.sh/releases) with `tg.ash` attached, then rebuilds [sstc/notify](https://github.com/docker-sstc/mono/tree/master/packages/notify), which bundles the latest release. See [.github/workflows/main.yml](.github/workflows/main.yml)

## TODO

- [sendMediaGroup](https://core.telegram.org/bots/api#sendmediagroup)
