#!/bin/bash
HOST_FILE="test.rc"
NUMBER_OF_NODES=2

echo "## begin ionadmin" > $HOST_FILE
    echo "1 $node 'node$node.ionconfig'" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "s" >> $HOST_FILE
    echo " " >> $HOST_FILE
    for ((first=1;first<=$NUMBER_OF_NODES;first++));
    do
        for ((second=1;second<=$NUMBER_OF_NODES;second++));
        do
            echo "a contact +1 +3600 $first $second 100000" >> $HOST_FILE
        done
    done
    echo " " >> $HOST_FILE

    for ((first=1;first<=$NUMBER_OF_NODES;first++));
    do
        for ((second=1;second<=$NUMBER_OF_NODES;second++));
        do
            echo "a range +1 +3600 $first $second 1" >> $HOST_FILE
        done
    done
    echo " " >> $HOST_FILE

    echo "m production 1000000" >> $HOST_FILE
    echo "m consumption 1000000" >> $HOST_FILE
    echo "## end ionadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "## begin ionsecadmin" >> $HOST_FILE
    echo "1" >> $HOST_FILE
    echo "## end ionsecadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "## begin ltpadmin" >> $HOST_FILE
    echo "1 32" >> $HOST_FILE
    echo " " >> $HOST_FILE
    for((span=1;span<=$NUMBER_OF_NODES;span++));
    do
        echo "a span $span 32 32 1400 10000 1 'udplso 10.1.1.$span:1113' 300" >> $HOST_FILE
    done
    echo " " >> $HOST_FILE
    echo "s 'udplsi 10.1.1.$node:1113'" >> $HOST_FILE
    echo "## end ltpadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE

    echo "## begin bpadmin" >> $HOST_FILE
    echo "1" >> $HOST_FILE
    echo "a scheme ipn 'ipnfw' 'ipnadminep'" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "a endpoint ipn:$node.0 q" >> $HOST_FILE
    echo "a endpoint ipn:$node.1 q" >> $HOST_FILE
    echo "a endpoint ipn:$node.2 q" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "a protocol ltp 1400 100" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "a induct ltp $node ltpcli" >> $HOST_FILE
    for ((outs=1;outs<=$NUMBER_OF_NODES;outs++));
    do
        echo "a outduct ltp $outs ltpclo" >> $HOST_FILE
    done
    echo " " >> $HOST_FILE
    echo "s" >> $HOST_FILE
    echo "## end bpadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "## begin ipnadmin" >> $HOST_FILE
    for ((plan=1;plan<=$NUMBER_OF_NODES;plan++))
    do
        echo "a plan $plan ltp/$plan" >> $HOST_FILE
    done
    echo "## end ipnadmin" >> $HOST_FILE
