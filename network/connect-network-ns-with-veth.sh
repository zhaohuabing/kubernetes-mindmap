#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@" 
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@" 
}

read -p "Press [Enter] key to create networkspaces..."
runthis "ip netns add ns1"
runthis "ip netns add ns2"
echo ""
runthis "ip netns"
echo ""

read -p "Press [Enter] key to link ns1 ns and ns2 with veth pair virtual link..."
runthis "ip link add veth-ns1 type veth peer name veth-ns2"
runthis "ip link set veth-ns1 netns ns1"
runthis "ip link set veth-ns2 netns ns2"
echo ""

read -p "Press [Enter] key to assign IP addresses to the veth inside ns1 and ns2..."
runthis "ip -n ns1 addr add 192.168.1.1/24 dev veth-ns1"
runthis "ip -n ns2 addr add 192.168.1.2/24 dev veth-ns2"
runthis "ip -n ns1 link set veth-ns1 up"
runthis "ip -n ns2 link set veth-ns2 up"
echo ""

read -p "Press [Enter] key to show ip addr in ns1..."
runthis "ip -n ns1 addr"
echo ""

read -p "Press [Enter] key to show ip addr in ns2..."
runthis "ip -n ns2 addr"
echo ""

read -p "Press [Enter] key to ping ns2 ns from ns1..."
runthis "ip netns exec ns1 ping 192.168.1.2"
echo ""

read -p "Press [Enter] key to clear up..."

runthis "ip netns delete ns1"
runthis "ip netns delete ns2"
