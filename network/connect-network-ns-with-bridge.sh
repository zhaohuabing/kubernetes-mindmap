#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@" 
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@" 
}

echo ""
echo "This experiment shows how to connect multiple namespaces through a linux bridge"
echo "+------------------+     +------------------+     +------------------+"
echo "|                  |     |                  |     |                  |"
echo "|                  |     |                  |     |                  |"
echo "|                  |     |                  |     |                  |"
echo "|       ns1        |     |       ns2        |     |       ns3        |"
echo "|                  |     |                  |     |                  |"
echo "|                  |     |                  |     |                  |"
echo "|                  |     |                  |     |                  |"
echo "|  192.168.1.1/24  |     |  192.168.1.2/24  |     |  192.168.1.3/24  |"
echo "+----(veth-ns1)----+     +----(veth-ns2)----+     +----(veth-ns3)----+"
echo "         +                          +                        +"
echo "         |                          |                        |"
echo "         |                          |                        |"
echo "         +                          +                        +"
echo "+--(veth-ns1-br)-------------(veth-ns2-br)------------(veth-ns3-br)--+"
echo "|                                                                    |"
echo "|                           virtual-bridge                           |"
echo "|                                                                    |"
echo "+--------------------------------------------------------------------+"
echo ""

read -p "Press [Enter] key to create networkspaces..."
runthis "ip netns add ns1"
runthis "ip netns add ns2"
runthis "ip netns add ns3"
echo ""
runthis "ip netns"
echo ""

read -p "Press [Enter] key to create a linux bridge..."
runthis "brctl addbr virtual-bridge"
runthis "brctl show virtual-bridge"
echo ""

read -p "Press [Enter] key to create veth pair to connect ns1 to the bridge..."
runthis "ip link add veth-ns1 type veth peer name veth-ns1-br"
runthis "ip link set veth-ns1 netns ns1"
runthis "brctl addif virtual-bridge veth-ns1-br"
echo ""

read -p "Press [Enter] key to create veth pair to connect ns2 to the bridge..."
runthis "ip link add veth-ns2 type veth peer name veth-ns2-br"
runthis "ip link set veth-ns2 netns ns2"
runthis "brctl addif virtual-bridge veth-ns2-br"
echo ""

read -p "Press [Enter] key to create veth pair to connect ns3 to the bridge..."
runthis "ip link add veth-ns3 type veth peer name veth-ns3-br"
runthis "ip link set veth-ns3 netns ns3"
runthis "brctl addif virtual-bridge veth-ns3-br"
echo ""

read -p "Press [Enter] key to assign IP addresses to each ns..."
runthis "ip -n ns1 addr add local 192.168.1.1/24 dev veth-ns1"
runthis "ip -n ns2 addr add local 192.168.1.2/24 dev veth-ns2"
runthis "ip -n ns3 addr add local 192.168.1.3/24 dev veth-ns3"
echo ""

read -p "Press [Enter] key to bring the devices up..."
runthis "ip link set virtual-bridge up"
runthis "ip link set veth-ns1-br up"
runthis "ip link set veth-ns2-br up"
runthis "ip link set veth-ns3-br up"
runthis "ip -n ns1 link set veth-ns1 up"
runthis "ip -n ns2 link set veth-ns2 up"
runthis "ip -n ns3 link set veth-ns3 up"
runthis "ip -n ns1 link set lo up"
runthis "ip -n ns2 link set lo up"
runthis "ip -n ns3 link set lo up"

read -p "Press [Enter] key to show ip addr in each namespace ..."
runthis "ip -n ns1 addr"
echo ""

runthis "ip -n ns2 addr"
echo ""

runthis "ip -n ns3 addr"
echo ""

read -p "Press [Enter] key to show virtual-bridge ..."
runthis "brctl show virtual-bridge"
echo ""

read -p "Press [Enter] key to ping ns2 ns from ns1 ns..."
runthis "ip netns exec ns1 ping 192.168.1.2"
echo ""

read -p "Press [Enter] key to clear up..."

runthis "ip netns delete ns1"
runthis "ip netns delete ns2"
runthis "ip netns delete ns3"
runthis "ip link set virtual-bridge down"
runthis "brctl delbr virtual-bridge"
