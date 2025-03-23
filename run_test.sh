#!/bin/bash

TELEGRAM_BOT_TOKEN=$(jq <./.config/telegram.org/config.json -r .token)
# TELEGRAM_CHAT_ID=$(jq <./.config/telegram.org/config.json -r .chat_id)
TELEGRAM_GROUP_ID=$(jq <./.config/telegram.org/config.json -r .group_id)
TELEGRAM_GROUP_THREAD_IDS=$(jq <./.config/telegram.org/config.json -r '.group_thread_ids | join("|")')

docker run --rm \
	-v $(pwd):/app \
	-w /app \
	-e TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN \
	-e TELEGRAM_CHAT_ID=$TELEGRAM_GROUP_ID \
	-e TELEGRAM_THREAD_IDS="$TELEGRAM_GROUP_THREAD_IDS" \
	sstc/notify \
	sh -c "rm /usr/local/bin/tg && env && ./test/cases.sh ./tg.ash"
