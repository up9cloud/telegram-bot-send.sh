#!/bin/bash -e

cd "$(dirname "$0")"
config=./.config/telegram.org/config.json

# Plain alpine, not sstc/notify: proves busybox + curl + jq is enough
docker run --rm \
	-v "$PWD":/app \
	-w /app \
	-e TELEGRAM_BOT_TOKEN="$(jq -r .token $config)" \
	-e TELEGRAM_CHAT_ID="$(jq -r .group_id $config)" \
	-e TELEGRAM_THREAD_IDS="$(jq -r '.group_thread_ids | join("|")' $config)" \
	alpine \
	sh -c 'apk add -q --no-cache curl jq && ./test/cases.sh ./tg.ash'
