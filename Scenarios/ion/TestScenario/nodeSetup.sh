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

if [ $IPN_NODE_NUMBER -eq "1" ]; then
    echo "Starting bping on node 1" >> $LOG
    
    bping ipn:1.2 ipn:3.1
    echo "bping started on ipn:1.2 pinging ipn:3.1" >> $LOG
elif [ $IPN_NODE_NUMBER -eq "3" ]; then
    echo "Starting bpecho on node 3" >> $LOG
    bpecho ipn:3.1
    echo "bpecho started on ipn:3.1" >> $LOG
fi

