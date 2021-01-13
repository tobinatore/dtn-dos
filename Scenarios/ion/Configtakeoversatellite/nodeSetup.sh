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
cp $BASE_DIR/bundlecount.sh .
if [ -f $BASE_DIR/ping.log ]
then
    rm -f $BASE_DIR/ping.log
fi
echo "Starting ION on node $IPN_NODE_NUMBER" >> $LOG

ionstart -I n$IPN_NODE_NUMBER.rc >> $LOG
LOG2=`dirname $SESSION_FILENAME`/node"$IPN_NODE_NUMBER".log
if [ $IPN_NODE_NUMBER -eq "1" ]; then
    
    echo "Starting bping on node 1" >> $LOG2
    bping ipn:1.1 ipn:4.1 > $BASE_DIR/ping.log &
    echo "bping started on ipn:1.1 sending to ipn:4.1" >> $LOG2
elif [ $IPN_NODE_NUMBER -eq "3" ]; then
     echo "Starting receivig ncat on node 3" >> $LOG2
    ncat 200 -l --udp | bash >> $LOG2 &
elif [ $IPN_NODE_NUMBER -eq "4" ]; then
    echo "Starting bpecho on node 4" >> $LOG2
    bpecho ipn:4.1 &
    echo "bpecho started on ipn:4.1" >> $LOG2
    echo "lgagent started on ipn:4.2" >> $LOG2
    lgagent ipn:4.2 >> $LOG2 &
    
elif [ $IPN_NODE_NUMBER -eq "5" ]; then
    echo "Starting ncat on node 5" >> $LOG2
    sleep 1
    cat script | ncat 10.0.3.1 200 --udp >> $LOG2
    echo "stopped ncat on node 5" >> $LOG2
fi


echo "Starting up bundlecount.sh" >> $LOG
sh bundlecount.sh "$IPN_NODE_NUMBER" 
echo "Running bundlecount.sh in the background." >> $LOG
