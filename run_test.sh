#!/bin/bash

TELEGRAM_BOT_TOKEN=$(jq <./.config/telegram.org/config.json -r .token)
TELEGRAM_CHAT_ID=$(jq <./.config/telegram.org/config.json -r .chat_id)

docker run --rm \
	-v $(pwd):/app \
	-w /app \
	-e TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN \
	-e TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID \
	sstc/notify \
	sh -c "rm /usr/local/bin/tg && env && ./test/cases.sh ./tg.ash"
