#!/bin/bash

APPNAME=$(basename $0 | sed "s/\.sh$//")

# Functions
fn_help() {
	echo 'help...'
}

fn_error() { echo "$APPNAME: [ERROR] $1" 1>&2; }

# Loop get parameters
while [ "$1" != "" ]; do
	case $1 in
		-h|-\?|--help)
			fn_help
			exit
			;;
		-e|--exclude)
			shift
			EXCLUDE+=("'$1'")
			;;
		-*)
			fn_error "Unknown option: \"$1\""
			echo ''
			fn_help
			exit 1
			;;
		*)
			SRC="$1"
			DEST="$2"
			shift
	esac

	shift
done

# If SRC or DEST not set
if [[ -z "$SRC" || -z "$DEST" ]]; then
	fn_help
	exit 1
fi

LOG_DIR="$HOME/.$APPNAME"

DATE=$(date +"%Y-%m-%d_%H:%M:%S")

# Create dirs
mkdir -p $DEST
mkdir -p $LOG_DIR

# Last backup
LASTBU=$(ls $DEST -t | head -n1)

LOGFILE=$LOG_DIR"/backup_log_"$DATE".log"

NEXTBU=$DEST$DATE
PREVBU=$DEST$LASTBU

# Generate command
RSYNC="rsync -avzh --no-owner --no-group --delete --log-file=$LOGFILE --link-dest=$PREVBU $SRC $NEXTBU";

# Append exclude
for i in "${EXCLUDE[@]}"; do
 RSYNC=$RSYNC' --exclude="'$i'"'
done

# Run
if (bash -c "$RSYNC")  then
	touch $NEXTBU
else
	fn_error "There was an error generating a new backup."
	rm -rf $NEXTBU
fi













