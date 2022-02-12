#!/bin/sh

function show_version() {
	cat <<EOL
Version: v${VERSION}
EOL
}

function show_help() {
	cat <<EOL
Issues: https://github.com/up9cloud/telegram-bot-send.sh/issues

Usage:
	${0} [options]
	${0} [options] [message]
	${0} [options] < [message file]

ENV:
	TELEGRAM_BOT_TOKEN      Bot token, get it by steps:
	                          - On telegram, call @BotFather
	                          - Execute /newbot or /mybots to find out
	TELEGRAM_CHAT_ID        Chat id, get it by steps:
	                          - On telegram, send a message to the bot.
	                          - Execute \`tg -X list_chat_ids\` to get recently chat ids.
	                          - find yourself and copy the id.

Options:
	-T,--bot-token=         Bot token. This will overwrite TELEGRAM_BOT_TOKEN.
	-I,--chat-id=           Chat id for the person or @channel_id for the channel, can be multiple times (-I ... -I ...)
	                        If this is set, the TELEGRAM_CHAT_ID will be ignored.
	-m,--message=           The message, could also be from STDIN, last argument. If --file provided, the message would be media caption.
	-f,--file=              Send file. (Must also specify --file-type)
	   --file-id=           Send file by the id existing on telegram server, this will overwrite --file. (Must also specify --file-type)
	-t,--file-type=         Shoude be one of: (see limitation at https://core.telegram.org/bots/api#inputfile)
	                          photo: <10MB (see https://core.telegram.org/bots/api#sendphoto)
	                          audio: .mp3, .m4a, <50MB (see https://core.telegram.org/bots/api#sendaudio)
	                          document: <50MB (see https://core.telegram.org/bots/api#senddocument)
	                          video: .mp4, <50MB (see https://core.telegram.org/bots/api#sendvideo)
	                          animation: GIF or H.264/MPEG-4 AVC video without sound, <50MB (see https://core.telegram.org/bots/api#sendanimation)
	                          voice: OGG file encoded with OPUS, <50MB (see https://core.telegram.org/bots/api#sendvoice)
	                          video_note: mp4, <1 mins (see https://core.telegram.org/bots/api#sendvideonote)
	                          sticker: WEBP or animated .TGS stickers (see https://core.telegram.org/bots/api#sendsticker)
	   --thumb=             Send file's thumb, only works with file type: audio, document, video, animation, video_note
	   --thumb-id=          Send file's thumb by id existing on telegram server, this will overwrite --thumb.
	-p,--parse-mode=        Should be one of: (see https://core.telegram.org/bots/api#formatting-options)
	                          '': Default, not set, plain text
	                          md: MarkdownV2
	                          html: HTML
	                          code: Add '\`\`\`' wrapping message string, and with md mode
	-x,--send-method=       Specify other send methods (not message nor file), might need provide more -o argument, should be one of:
	                          location: -o latitude= -o longitude= (see https://core.telegram.org/bots/api#sendgame)
	                          venue: -o latitude= -o longitude= -o title= -o address= (see https://core.telegram.org/bots/api#sendvenue)
	                          contact: -o phone_number= -o first_name= (see https://core.telegram.org/bots/api#sendcontact)
	                          poll: -o question= -o options= (see https://core.telegram.org/bots/api#sendpoll)
	                          dice: [-o emoji=] (see https://core.telegram.org/bots/api#senddice)
	                          chat_action: -o action= (see https://core.telegram.org/bots/api#sendchataction)
	                          invoice: -o title= -o description= -o payload= -o provider_token= -o  start_parameter= -o currency= -o prices= (see https://core.telegram.org/bots/api#sendinvoice)
	                          game: -o game_short_name= (see https://core.telegram.org/bots/api#sendgame)
	   --method=            Specify telegram api method, e.q. getUpdates, getMe, ...
	   --curl-form=         Set more argument via 'curl --form' for api
	-o,--curl-form-string=  Set more argument via 'curl --form-string' for api, e.q.:
	                          -o "disable_notification=true"
	                          -o "disable_web_page_preview=true"
	                          (see more options at https://core.telegram.org/bots/api#available-methods)
	   --curl-args=         Set default curl arguments, default is "-s"
	-X,--execute=           Execute built in functions, should be one of:
	                          list_deps: list dependencies
	                          check_deps: check dependencies existing
	                          list_chat_ids: parse api /getUpdates result and list all valid ids
	                          list_dice_emoji: show list of emojis
	                          random_dice: -x dice by random emoji
	                          list_chat_action: show list of actions of chat_action
	                          random_chat_action: -x chat_action by random action
	-h,--help               Display this help.
	-V,--version            Display version.
	-v,--verbose            Display verbose logs. If you want more verbose at curl, do --curl-args "--trace-ascii -".
	-q,--quiet              Hide success response.
	-n,--dry-run            Dry run, don't actually call the api, only print the curl command.

Examples: (see more examples at https://github.com/up9cloud/telegram-bot-send.sh/blob/master/test/cases.sh)
	TELEGRAM_BOT_TOKEN=123456:xxxxxx TELEGRAM_CHAT_ID=654321
	$0 "hello world"
	$0 -T 123456:xxxxxx -I @channel_id -m "hello world"
	$0 -p md < ./test/foo.md
	$0 -f ./test/foo.jpg -t photo "My photo"
	$0 -x location -o latitude=25.033713 -o longitude=121.564928
	$0 --method getMe
	$0 -X random_dice
EOL
}

function say() {
	if [ "$QUIET" != true ]; then
		printf '%s\n' "$@"
	fi
}

function log() {
	if [ "$VERBOSE" = true ]; then
		printf '[DEBUG] %s\n' "$@"
	fi
}

function error() {
	printf '%s\n' "$@" 1>&2
}

function die() {
	error "$@"
	exit 1
}

function check_dep() {
	if ! command -v $1 &>/dev/null; then
		die "Command '$1' not found."
	fi
}

function list_deps() {
	cat <<EOL
getopt
cat
wc
awk
sed
curl
jq
EOL
}

function check_deps() {
	for c in $(list_deps | sed 's/\n/ /g'); do
		check_dep $c
	done
}

function curl_add_form() {
	CURL_ARGS=$(printf '%s --form "%s"' "$CURL_ARGS" "$1")
}

function curl_add_form_string() {
	CURL_ARGS=$(printf '%s --form-string "%s"' "$CURL_ARGS" "$1")
}

function action_handle() {
	local action=$1
	local parse=$2

	case $action in
	list_chat_ids)
		cmd=$(printf 'curl %s %s' "$CURL_DEFAULT_ARGS" "$API_BASE_URL/bot$BOT_TOKEN/getUpdates")
		jq_args='.result | .[] | select(.message != null) | .message.chat | "\(.id|tostring) - \(.first_name) \(.last_name) (@\(.username))"'
		;;
	*)
		die "Invalid action: ${action}"
		;;
	esac

	if [ "$DRY_RUN" = true ]; then
		say "Run command: $cmd"
		if [ -n "$jq_args" ]; then
			say "Run jq filter: $jq_args"
		fi
		exit 0
	fi

	local response=$(eval $cmd)
	local code=$?
	log "Command executed: $cmd"

	if [ $code -ne 0 ]; then
		die "curl exit with non 0 code ($code): $response"
	fi

	if [ "$(printf '%s' "$response" | jq -r '.ok')" != "true" ]; then
		die "Telegram bot api response error: $response"
	fi

	if [ "$parse" != false ]; then
		cmd=$(printf "jq -r '%s'" "$jq_args")
		printf '%s' "$response" | eval $cmd 2>/dev/null || {
			die "Failed to parse telegram response: $response"
		}
	else
		say "$response"
	fi

	exit 0
}

function list_dice_emoji() {
	cat <<EOL
🎲	1-6
🎯	1-6
🏀	1-5
⚽	1-5
🎳	1-6
🎰	1-64
EOL
}

function list_chat_action() {
	cat <<EOL
typing
upload_photo
record_video
upload_video
record_audio
upload_audio
upload_document
find_location
record_video_note
upload_video_note
EOL
}

VERSION=1.1.0
VERBOSE=false
DRY_RUN=false
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
	BOT_TOKEN=$TELEGRAM_BOT_TOKEN
fi
API_BASE_URL="https://api.telegram.org"
CURL_DEFAULT_ARGS="-s"
CURL_ARGS=""

# https://git.busybox.net/busybox/tree/util-linux/getopt.c
SHORT_OPTSTRING=hVvqnT:I:m:f:t:p:x:o:X:
LONG_OPTSTRING=help,version,verbose,quiet,dry-run,bot-token:,chat-id:,message:,file:,file-id:,file-type:,thumb:,thumb-id:,parse-mode:,send-method:,method:,curl-form:,curl-form-string:,curl-args:,execute:
GETOPT=$(getopt -o "${SHORT_OPTSTRING}" -l "${LONG_OPTSTRING}" -- "$@") || exit 1
eval set -- "$GETOPT"
while true; do
	case $1 in
	-h | --help)
		show_help
		exit 0
		;;
	-V | --version)
		show_version
		exit 0
		;;
	-v | --verbose)
		VERBOSE=true
		log "Set VERBOSE=true"
		shift
		;;
	-q | --quiet)
		QUIET=true
		log "Set QUIET=true"
		shift
		;;
	-n | --dry-run)
		DRY_RUN=true
		log "Set DRY_RUN=true"
		shift
		;;
	-T | --bot-token)
		BOT_TOKEN="$2"
		shift 2
		;;
	-I | --chat-id)
		if [ -z "$CHAT_IDS" ]; then
			CHAT_IDS="$2"
		else
			CHAT_IDS="$CHAT_IDS|$2"
		fi
		shift 2
		;;
	-m | --message)
		MESSAGE="$2"
		shift 2
		;;
	-f | --file)
		FILE_PATH="$2"
		shift 2
		;;
	--file-id)
		FILE_ID="$2"
		shift 2
		;;
	-t | --file-type)
		FILE_TYPE="$2"
		shift 2
		;;
	--thumb)
		FILE_THUMB="$2"
		shift 2
		;;
	--thumb-id)
		FILE_THUMB_ID="$2"
		shift 2
		;;
	-p | --parse-mode)
		PARSE_MODE="$2"
		shift 2
		;;
	-x | --send-method)
		case $2 in
		location)
			api_method="sendLocation"
			;;
		venue)
			api_method="sendVenue"
			;;
		contact)
			api_method="sendContact"
			;;
		poll)
			api_method="sendPoll"
			;;
		dice)
			api_method="sendDice"
			;;
		chat_action)
			api_method="sendChatAction"
			;;
		invoice)
			api_method="sendInvoice"
			;;
		game)
			api_method="sendGame"
			;;
		*)
			die "Invalid send method: ${2}"
			;;
		esac
		log "$1 '$2' will be api method: $api_method"
		shift 2
		;;
	--method)
		api_method="$2"
		shift 2
		;;
	--curl-form)
		curl_add_form "$2"
		shift 2
		;;
	-o | --curl-form-string)
		curl_add_form_string "$2"
		shift 2
		;;
	--curl-args)
		CURL_DEFAULT_ARGS="$2"
		shift 2
		;;
	-X | --execute)
		EXECUTE_ACTION="$2"
		shift 2
		;;
	--)
		shift
		break
		;;
	*)
		die "Invalid option: $1"
		;;
	esac
done
log "Formated args: $GETOPT"

if [ -z "$BOT_TOKEN" ]; then
	die "Must specify bot token. (TELEGRAM_BOT_TOKEN or -t)"
fi

if [ -n "$EXECUTE_ACTION" ]; then
	case $EXECUTE_ACTION in
	list_chat_ids)
		action_handle $EXECUTE_ACTION true
		;;
	random_dice)
		api_method="sendDice"
		list="$(list_dice_emoji | awk '{ print $1 }')"
		count=$(echo "$list" | wc -l)
		i=$(shuf -i 1-${count} -n 1)
		item=$(echo "$list" | sed "${i}q;d")
		curl_add_form_string "emoji=${item}"
		;;
	random_chat_action)
		api_method="sendChatAction"
		list="$(list_chat_action | awk '{ print $1 }')"
		count=$(echo "$list" | wc -l)
		i=$(shuf -i 1-${count} -n 1)
		item=$(echo "$list" | sed "${i}q;d")
		curl_add_form_string "action=${item}"
		;;
	*)
		${EXECUTE_ACTION}
		exit 0
		;;
	esac
fi

if [ -z "$CHAT_IDS" ]; then
	if [ -n "$TELEGRAM_CHAT_ID" ]; then
		CHAT_IDS="$TELEGRAM_CHAT_ID"
	else
		die "Must specify chat id. (TELEGRAM_CHAT_ID or -I)"
	fi
fi

if [ -z "$MESSAGE" ]; then
	if [ -n "$1" ]; then
		MESSAGE="$@"
		log "Message set from \$@"
	elif [ ! -t 0 ]; then
		MESSAGE=$(cat /dev/stdin)
		log "Message set from /dev/stdin"
	fi
fi

if [ -n "$FILE_PATH" ]; then
	if [ ! -e "$FILE_PATH" ]; then
		die "File $FILE_PATH does not exist."
	fi
	size=$(stat -c%s "$FILE_PATH")
	if [ "$size" -gt "52428800" ]; then
		die "File $FILE_PATH too large, size should not be > 50MB."
	fi
	case $FILE_TYPE in
	photo)
		api_method="sendPhoto"
		curl_add_form "photo=@$FILE_PATH"
		curl_add_form "caption=<-"
		;;
	audio)
		api_method="sendAudio"
		curl_add_form "audio=@$FILE_PATH"
		curl_add_form "caption=<-"
		;;
	document)
		api_method="sendDocument"
		curl_add_form "document=@$FILE_PATH"
		curl_add_form "caption=<-"
		;;
	video)
		api_method="sendVideo"
		curl_add_form "video=@$FILE_PATH"
		curl_add_form "caption=<-"
		;;
	animation)
		api_method="sendAnimation"
		curl_add_form "animation=@$FILE_PATH"
		curl_add_form "caption=<-"
		;;
	voice)
		api_method="sendVoice"
		curl_add_form "voice=@$FILE_PATH"
		curl_add_form "caption=<-"
		;;
	video_note)
		api_method="sendVideoNote"
		curl_add_form "video_note=@$FILE_PATH"
		;;
	sticker)
		api_method="sendSticker"
		curl_add_form "sticker=@$FILE_PATH"
		;;
	*)
		die "Invalid file type: ${FILE_TYPE}"
		;;
	esac
	log "Because of file type: $FILE_TYPE, api method be set to '$api_method'."
	if [ -n "$FILE_THUMB_ID" ]; then
		curl_add_form "thumb=${FILE_THUMB_ID}"
	elif [ -n "$FILE_THUMB_PATH" ]; then
		curl_add_form "thumb=@${FILE_THUMB_PATH}"
	fi
elif [ -n "$api_method" ]; then
	# Already specify a method, do nothing.
	log "Use api method: $api_method"
else
	if [ -z "$MESSAGE" ]; then
		die "Must provide message."
	fi
	api_method="sendMessage"
	log "Use default api method: $api_method"
	curl_add_form "text=<-"
fi

if [ -n "$PARSE_MODE" ]; then
	case $PARSE_MODE in
	md)
		curl_add_form_string "parse_mode=MarkdownV2"
		;;
	html)
		curl_add_form_string "parse_mode=HTML"
		;;
	code)
		MESSAGE='```'$'\n'$MESSAGE$'\n''```'
		curl_add_form_string "parse_mode=MarkdownV2"
		;;
	*)
		curl_add_form_string "parse_mode=${PARSE_MODE}"
		;;
	esac
fi

ISF="|"
for chat_id in $CHAT_IDS; do
	cmd=$(printf 'curl %s %s --form-string "chat_id=%s" %s' "$CURL_DEFAULT_ARGS" "$CURL_ARGS" "$chat_id" "$API_BASE_URL/bot$BOT_TOKEN/$api_method")

	if [ "$DRY_RUN" = true ]; then
		say "Run command: $cmd"
		exit 0
	fi

	response=$(printf '%s' "$MESSAGE" | eval $cmd)
	code=$?
	log "Command executed: $cmd"

	if [ $code -ne 0 ]; then
		die "curl exit with non 0 code ($code): $response"
	fi

	if [ "$(printf '%s' "$response" | jq -r '.ok')" != "true" ]; then
		die "Telegram bot api response error: $response"
	fi

	say "$response"

done
