#!/bin/bash

APPNAME=$(basename $0 | sed "s/\.sh$//")

# Functions
fn_help() {
	local bold_start=$(tput bold)
	local bold_end=$(tput sgr0)
	echo "${bold_start}SYNOPSIS${bold_end}"
    echo "	${bold_start}irb${bold_end} SOURCE DEST [OPTION]..."
	echo "${bold_start}OPTIONS${bold_end}"
	echo "	${bold_start}-e${bold_end} PATTERN"
	echo "		exclude files matching PATTERN" 
}

fn_error() { echo "$APPNAME: [ERROR] $1" 1>&2; }

fn_trailing_slash() {
	local STR=$1
	local length=${#STR}
	local last_char=${STR:length-1:1}

	[[ $last_char != "/" ]] && STR="$STR/"; :
	echo $STR
}

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

SRC=$(fn_trailing_slash $SRC)
DEST=$(fn_trailing_slash $DEST)

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
 RSYNC=$RSYNC' --exclude='$i
done

# Run
if (bash -c "$RSYNC")  then
	touch $NEXTBU
else
	fn_error "There was an error generating a new backup."
	rm -rf $NEXTBU
fi













