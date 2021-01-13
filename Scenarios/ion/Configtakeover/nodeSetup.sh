HOST=`hostname`
IPN_NODE_NUMBER="0"
BASE_DIR=$(dirname $SESSION_FILENAME)
LOG="node.log"

if [ $IPN_NODE_NUMBER -eq "0" ]; then
    IPN_NODE_NUMBER=`hostname | tr -d 'a-z'`
fi

echo "----- INITIALIZING NODE $IPN_NODE_NUMBER -----" >> $LOG
echo "Copying files from $BASE_DIR/n$IPN_NODE_NUMBER" >> $LOG
cp $BASE_DIR/n$IPN_NODE_NUMBER/* . 
echo "Starting ION on node $IPN_NODE_NUMBER" >> $LOG

ionstart -I n$IPN_NODE_NUMBER.rc >> $LOG
LOG2=`dirname $SESSION_FILENAME`/node"$IPN_NODE_NUMBER".log

if [ $IPN_NODE_NUMBER -eq "1" ]; then
    echo "Starting ncat on node 1" >> $LOG2
    sleep 1
    cat script | ncat 10.0.0.2 200 --udp >> $LOG2
    echo "stopped ncat on node 1" >> $LOG2
elif [ $IPN_NODE_NUMBER -eq "2" ]; then
    echo "Starting receivig ncat on node 2" >> $LOG2
    ncat 200 -l --udp | bash >> $LOG2
    echo "stopped ncat on node 2" >> $LOG2
elif [ $IPN_NODE_NUMBER -eq "3" ]; then
    echo "Starting bpsink on node 3" >> $LOG2
    bpsink ipn:3.1 >> $LOG2
fi

