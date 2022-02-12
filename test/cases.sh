#!/bin/sh -e

if ! command -v tg &>/dev/null; then
	# Testing wrapper
	TG_CMD="$1"
	function tg() {
		local cmd=$(printf '%s %s' "$TG_CMD" "$*")
		echo "===>>> $@"
		$cmd
		exitCode=$?
		echo "<<<=== $exitCode"
		if [ $exitCode != 0 ]; then
			exit $exitCode
		fi
	}
fi

tg --help
tg -h
tg --version
tg -V

# message
tg "msg by env"
tg -v "verbose mode"
tg -T "${TELEGRAM_BOT_TOKEN}" -I "${TELEGRAM_CHAT_ID}" "msg by opt"
tg -p md <./test/foo.md
tg -p code <./test/foo.sh

# file
tg -f ./test/foo.jpg -t photo "My photo"
tg -f ./test/foo.mp3 -t audio "My audio"
tg -f ./test/foo.md -t document "My document"
tg -f ./test/foo.mp4 -t video "My video"
tg -f ./test/foo.gif -t animation "My animation"
tg -f ./test/foo.ogg -t voice "My voice"
tg -f ./test/foo.mp4 -t video_note "My video_note"
tg -f ./test/foo.webp -t sticker "My sticket"

# others
tg -x location -o latitude=25.033713 -o longitude=121.564928
tg -x venue -o latitude=25.033713 -o longitude=121.564928 -o title=101 -o address=taipei
tg -x contact -o "phone_number=2125802000" -o "first_name=Eva"
tg -x poll -o "question=Which?" -o "options=$(printf '[]' | jq -c '.[0] |= "a" | .[1] += "b" | tostring')"
tg -x dice
tg -x chat_action -o action=typing
# tg -x invoice -o title=Invoice -o description="So cheap!" -o payload=secret -o start_parameter=unique -o currency=USD -o 'prices=[{\"label\":\"Beer\",\"amount\":123}]' -o provider_token=...
tg -x game -o game_short_name="testgame"

# tg api
tg --method=getUpdates
tg --method=getMe

# built-in methods
tg -X list_deps
tg -X check_deps
tg -X list_chat_ids
tg -X list_dice_emoji
tg -X random_dice
tg -X list_chat_action
tg -X random_chat_action
