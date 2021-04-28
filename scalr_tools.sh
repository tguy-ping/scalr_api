#!/usr/bin/env bash

# get the environment variables, if set
API_SERVER=$SCALR_API_SERVER
API_KEY=$SCALR_API_KEY
API_SECRET=$SCALR_API_SECRET
ENV_ID=$SCALR_ENV_ID
SERVER_ID=$SCALR_SERVER_ID

USAGE_TASK="
	server-action
	request
	signature"

USAGE_FLAGS="
	-a    |  --server 	<your SCALR host>
	-k    |  --api-key	<Key with permissions for server/farm>
	-s    |  --api-secret	<Secret with permissions for server/farm>
	-e    |  --env-id	<environment id>
	-sid  |  --server-id	<server id of target>"

USAGE_ACTIONS="
	status
	resume
	suspend
	sync
	terminate"

# input: http-method path [formatted_date qs body]
# output: signature
generate_signature () {
	exit_empty 'API method' "$1"
	exit_empty 'API path' "$2"
	exit_empty 'API secret' "$API_SECRET"
	typeset FORMATTED_DATE="${3:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}"	
	typeset CANONICAL_REQUEST="$1"$'\n'"$FORMATTED_DATE"$'\n'"$2"$'\n'"$4"$'\n'"$5"
	typeset SIG=$(printf '%s' "$CANONICAL_REQUEST" | openssl sha256 -hmac "$API_SECRET" -binary | base64)
	echo "$SIG"
}

# input: http-method path [qs body]
# output: response
call_api () {
	exit_empty 'API server' "$API_SERVER"
	# date for header and signature
	typeset FORMATTED_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
	# http-method formatted_date path qs body secret
	typeset SIGNED_STRING=$(generate_signature "$1" "$2" "$FORMATTED_DATE" "$4" "$5")
	exit_empty 'Signature string' "$SIGNED_STRING"
	typeset SIG_HEADER=$(printf 'X-Scalr-Signature: V1-HMAC-SHA256 %s' "$SIGNED_STRING")
	typeset KEY_HEADER=$(printf 'X-Scalr-Key-Id: %s' "$API_KEY")
	typeset DATE_HEADER=$(printf 'X-Scalr-Date: %s' "$FORMATTED_DATE")
	typeset DEBUG_HEADER=$(printf 'X-Scalr-Debug: %s' "1")

	typeset RESPONSE=$(curl -s -X "$1" -H "$KEY_HEADER" -H "$DATE_HEADER" -H "$DEBUG_HEADER" -H "$SIG_HEADER" "$API_SERVER$2")

	exit_empty 'curl response' "$RESPONSE"
	echo "$RESPONSE"
}

# input: action env_id server_id
# output: server-action-response
server_action () {
	exit_empty 'Action' "$1"
	exit_empty 'Environment ID' "$2"
	exit_empty 'Server ID' "$3"
	case $1 in
		status)
			call_api 'GET' "/api/v1beta0/user/${2}/servers/${3}/"
			;;
		reboot|resume|suspend|sync|terminate)
			call_api 'POST' "/api/v1beta0/user/${2}/servers/${3}/actions/${1}/"
			;;
		*)
			exit_error "unsupported action $1"
			exit 1
			;;
	esac
}

do_signature () {
	for word; do
		case "$word" in
			GET|POST|PUT|DELETE)
				METHOD="$word"
				shift
				;;
			/api/v1beta0/*)
				API_PATH="$word"
				shift
				;;
			????-??-??T*)
				FORMATTED_DATE="$word"
				shift
				;;
			*)
				# if there are any more args, treat them as the query string and body
				QUERY_STRING="$word"
				shift
				BODY="$word"
				shift
				;;
		esac
	done
	# input: http-method path [formatted_date qs body]
	generate_signature "$METHOD" "$API_PATH" "$FORMATTED_DATE" "$QUERY_STRING" "$BODY"
}

do_manual_request () {
	for word; do
		case "$word" in
			GET|POST|PUT|DELETE)
				METHOD="$word"
				shift
				;;
			/api/v1beta0/*)
				API_PATH="$word"
				shift
				;;
			*)
				# if there are any more args, treat them as the query string and body
				QUERY_STRING="$word"
				shift
				BODY="$word"
				shift
				;;
		esac
	done
	# input: http-method path [qs body]
	# output: response
	call_api "$METHOD" "$API_PATH" "$QUERY_STRING" "$BODY"
}

do_server_action () {
	for word; do
		case $word in
			status|reboot|resume|suspend|sync|terminate)
				ACTION=$word
				shift
				;;
			*-*-*-*-*)
				# Only set server_id if it wasn't already passed
				if [ -z "$SERVER_ID" ] ; then
					SERVER_ID=$word
				fi
				shift
				;;
			*)
				printf 'Unsupported argument: "%s"' "$word" >&2
				exit 1
				;;
		esac
	done
	# input: action env_id server_id
	server_action "$ACTION" "$ENV_ID" "$SERVER_ID"
}

exit_empty () {
	if [ -z "$2" ] || [[ "$#" -lt 2 ]] ; then
		exit_error "$1 is empty or missing!"
	fi
}

exit_missing_arg () {
	if [ -z "$2" ] || [[ "$#" -lt 2 ]] || [ "${2:0:1}" = "-" ]; then
		"Error: Argument for $1 is missing"
		usage
	fi
}

exit_error () {
	printf 'Error: %s\n' "$1" >&2
    exit 1
}

usage () {
	echo "Usage: $0 <task> [flags] <action> <server-id>"
	echo "Task: $USAGE_TASK"
	echo "Flags: $USAGE_FLAGS"
	echo "Actions: $USAGE_ACTIONS"
	exit 1
}


# take the first arg as the task
case "$1" in
	s|sign|signature)
		TASK='SIGN'
		;;
	a|action|server-action)
		TASK='SERVER_ACTION'
		;;
	m|manual|request)
		TASK='MANUAL_REQUEST'
		;;
	*)
		printf 'Unrecognized task: %s\n' "$1"
		usage
		;;
esac
shift

# global var to hold args
ST_PARAMS=''
# process the flags
while [[ "$#" -gt 0 ]]; do
	case "$1" in
		-a|--server)
			exit_missing_arg "$1" "$2"
        	API_SERVER=$2
        	shift 2
			;;
		-k|--api-key)
			exit_missing_arg "$1" "$2"
        	API_KEY=$2
        	shift 2
			;;
		-s|--api-secret)
			exit_missing_arg "$1" "$2"
        	API_SECRET=$2
        	shift 2
			;;
		-e|--env-id|--environment-id)
			exit_missing_arg "$1" "$2"
        	ENV_ID=$2
        	shift 2
			;;
		-sid|--server-id)
			exit_missing_arg "$1" "$2"
        	SERVER_ID=$2
        	shift 2
			;;
		--*|-*) # unsupported flags
			exit_error "Error: Unsupported flag $1"
			;;
		*) # preserve positional arguments
			ST_PARAMS="$ST_PARAMS $1"
			shift
			;;
	esac
done
# set positional arguments in their proper place
eval set -- "$ST_PARAMS"

# process the remaining params and execute
case "$TASK" in
	SIGN)
		do_signature "$@"
		;;
	MANUAL_REQUEST)
		do_manual_request "$@"
		;;
	SERVER_ACTION)
		do_server_action "$@"
		;;
esac

