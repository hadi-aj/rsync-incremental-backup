#!/bin/bash
#config
#SRC="ssh@1.1.1.1:/tmp/test"
SRC="/tmp/test"
EXCLUDE=('*.tgz' '/cache')

DEST="/tmp/backup/"

#---------------------------------------------
DATE=$(date +"%Y-%m-%d_%H:%M:%S")

#create backup dir
mkdir -p $DEST

#last backup
LASTBU=$(ls $DEST -t | head -n1)

LOGFILE="backup_log_"$DATE

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













