#!/bin/bash
#config
#SRC="ssh@1.1.1.1:/tmp/test"
SRC="/tmp/test"
EXCLUDE=('*.tgz' '/cache')

DEST="/tmp/backup/"

#---------------------------------------------
APPNAME=$(basename $0 | sed "s/\.sh$//")
LOG_DIR="$HOME/.$APPNAME"

DATE=$(date +"%Y-%m-%d_%H:%M:%S")

#create dirs
mkdir -p $DEST
mkdir -p $LOG_DIR

#last backup
LASTBU=$(ls $DEST -t | head -n1)

LOGFILE=$LOG_DIR"/backup_log_"$DATE".log"

NEXTBU=$DEST$DATE
PREVBU=$DEST$LASTBU

#generate command
RSYNC="rsync -avzh --no-owner --no-group --delete --log-file=$LOGFILE --link-dest=$PREVBU $SRC $NEXTBU";

#append exclude
for i in "${EXCLUDE[@]}"; do
 RSYNC=$RSYNC' --exclude="'$i'"'
done

#run
if (bash -c "$RSYNC")  then
	touch $NEXTBU
else
	echo "There was an error generating a new backup."
        rm -rf $NEXTBU
fi













