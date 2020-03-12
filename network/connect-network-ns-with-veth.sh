#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@" 
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@" 
}

read -p "Press [Enter] key to create networkspaces..."
runthis "ip netns add red"
runthis "ip netns add blue"
echo ""
runthis "ip netns"
echo ""

read -p "Press [Enter] key to link red ns and blue ns with veth pair virtual link..."
runthis "ip link add veth-red type veth peer name veth-blue"
runthis "ip link set veth-red netns red"
runthis "ip link set veth-blue netns blue"
echo ""

read -p "Press [Enter] key to assign IP addresses to the veth inside red and blue ns..."
runthis "ip -n red addr add 192.168.1.1/24 dev veth-red"
runthis "ip -n blue addr add 192.168.1.2/24 dev veth-blue"
runthis "ip -n red link set veth-red up"
runthis "ip -n blue link set veth-blue up"
echo ""

read -p "Press [Enter] key to show ip addr in red ns ..."
runthis "ip -n red addr"
echo ""

read -p "Press [Enter] key to show ip addr in blue ns ..."
runthis "ip -n blue addr"
echo ""

read -p "Press [Enter] key to ping blue ns from red ns..."
runthis "ip netns exec red ping 192.168.1.2"
echo ""

read -p "Press [Enter] key to clear up..."

runthis "ip netns delete red"
runthis "ip netns delete blue"
