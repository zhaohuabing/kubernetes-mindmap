#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@" 
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@" 
}
if [ "$1" == "" ]; then
    echo "Please specify host IP address"
    exit
fi

echo ""
echo "This experiment shows how to connect multiple namespaces to the outside world"
echo ""
echo "route: default gw 192.168.1"
echo "+------------------+     +------------------+"
echo "|                  |     |                  |"
echo "|                  |     |                  |"
echo "|                  |     |                  |"
echo "|       ns1        |     |       ns2        |"
echo "|                  |     |                  |"
echo "|                  |     |                  |"
echo "|                  |     |                  |"
echo "|  192.168.1.2/24  |     |  192.168.1.3/24  |"
echo "+---+(veth+ns1)+---+     +---+(veth+ns2)+---+"
echo "         +                          +"
echo "         |                          |"
echo "         |                          |"
echo "         +                          +"
echo "+-+(veth+ns1+br)+-----------+(veth+ns2+br)+-+"
echo "|                                           |"
echo "|               Linux bridge                |"
echo "|                                           |"
echo "+-----------------(br0)---------------------+"
echo "                    |"
echo "                    |"
echo "                    |"
echo "+-----------------(br0)---------------------+"
echo "|            192.168.1.1/24                 |"
echo "|        default network namespace          |"
echo "|       (Linux Kernel IP Forwarding)        |"
echo "|                                           |"
echo "|              10.0.2.15/24                 |"
echo "+---------------(enp0s3)--------------------+"
echo ""

read -p "Press [Enter] key to create networkspaces..."
runthis "ip netns add ns1"
runthis "ip netns add ns2"
echo ""
runthis "ip netns"
echo ""

read -p "Press [Enter] key to create a linux bridge..."
runthis "brctl addbr br0"
runthis "brctl show br0"
echo ""

read -p "Press [Enter] key to create veth pair to connect ns1 to the bridge..."
runthis "ip link add veth-ns1 type veth peer name veth-ns1-br"
runthis "ip link set veth-ns1 netns ns1"
runthis "brctl addif br0 veth-ns1-br"
echo ""

read -p "Press [Enter] key to create veth pair to connect ns2 to the bridge..."
runthis "ip link add veth-ns2 type veth peer name veth-ns2-br"
runthis "ip link set veth-ns2 netns ns2"
runthis "brctl addif br0 veth-ns2-br"
echo ""

read -p "Press [Enter] key to assign IP addresses to each ns and the bridge..."
runthis "ip -n ns1 addr add local 192.168.1.2/24 dev veth-ns1"
runthis "ip -n ns2 addr add local 192.168.1.3/24 dev veth-ns2"
runthis "ip addr add local 192.168.1.1/24 dev br0"
echo ""

read -p "Press [Enter] key to bring the devices up..."
runthis "ip link set br0 up"
runthis "ip link set veth-ns1-br up"
runthis "ip link set veth-ns2-br up"
runthis "ip -n ns1 link set veth-ns1 up"
runthis "ip -n ns2 link set veth-ns2 up"

read -p "Press [Enter] key to show ip addr in each namespace ..."
runthis "ip -n ns1 addr"
echo ""

read -p ""
runthis "ip -n ns2 addr"
echo ""

read -p "Press [Enter] key to show bridge ..."
runthis "brctl show br0"
echo ""

read -p "Press [Enter] key to ping ns2 and br0 from ns1..."
runthis "ip netns exec ns1 ping 192.168.1.1"
runthis "ip netns exec ns1 ping 192.168.1.3"
echo ""

read -p "Press [Enter] key to ping host from ns1..."
runthis "ip netns exec ns1 ping "$1
echo ""

read -p "Press [Enter] key to add routes..."
runthis "ip netns exec ns1 ip route add default via 192.168.1.1"
runthis "ip netns exec ns2 ip route add default via 192.168.1.1"

read -p "Press [Enter] key to ping host from ns1..."
runthis "ip netns exec ns1 ping "$1
runthis "ip netns exec ns2 ping "$1
echo ""

read -p "Press [Enter] key to clear up..."

runthis "ip netns delete ns1"
runthis "ip netns delete ns2"
runthis "ip link set br0 down"
runthis "brctl delbr br0"
