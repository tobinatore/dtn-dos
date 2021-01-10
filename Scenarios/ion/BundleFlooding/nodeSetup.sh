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

if [ $IPN_NODE_NUMBER -eq "1" ]; then
    
    echo "Starting bping on node 1" >> $LOG
    bping ipn:1.1 ipn:4.1 > $BASE_DIR/ping.log &
    echo "bping started on ipn:1.1 sending to ipn:4.1" >> $LOG
elif [ $IPN_NODE_NUMBER -eq "4" ]; then
    echo "Starting bpecho on node 4" >> $LOG
    bpecho ipn:4.1 &
    echo "bpecho started on ipn:4.1" >> $LOG
elif [ $IPN_NODE_NUMBER -eq "5" ]; then
    sleep 10
    echo "Starting bpings on node 5" >> $LOG
    bping -i 0.2 -p 2 ipn:5.1 ipn:4.1 &
    echo "bping started on ipn:5.1 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.2 ipn:4.1 &
    echo "bping started on ipn:5.2 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.3 ipn:4.1 &
    echo "bping started on ipn:5.3 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.4 ipn:4.1 &
    echo "bping started on ipn:5.4 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.5 ipn:4.1 &
    echo "bping started on ipn:5.5 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.6 ipn:4.1 &
    echo "bping started on ipn:5.6 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.7 ipn:4.1 &
    echo "bping started on ipn:5.7 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.8 ipn:4.1 &
    echo "bping started on ipn:5.8 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.9 ipn:4.1 &
    echo "bping started on ipn:5.9 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.10 ipn:4.1 &
    echo "bping started on ipn:5.10 pinging ipn:4.1" >> $LOG
    bping -i 0.2 -p 2 ipn:5.11 ipn:4.1 &
    echo "bping started on ipn:5.11 pinging ipn:4.1" >> $LOG
    
fi


echo "Starting up bundlecount.sh" >> $LOG
sh bundlecount.sh "$IPN_NODE_NUMBER" 
echo "Running bundlecount.sh in the background." >> $LOG
