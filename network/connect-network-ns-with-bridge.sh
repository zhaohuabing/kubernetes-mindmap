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

read -p "Press [Enter] key to create a linux bridge..."
runthis "brctl addbr virtual-bridge"
runthis "brctl show virtual-bridge"
echo ""

read -p "Press [Enter] key to create veth pair to connect red ns to the bridge..."
runthis "ip link add veth-red type veth peer name veth-red-br"
runthis "ip link set veth-red netns red"
runthis "brctl addif virtual-bridge veth-red-br"
echo ""

read -p "Press [Enter] key to create veth pair to connect blue ns to the bridge..."
runthis "ip link add veth-blue type veth peer name veth-blue-br"
runthis "ip link set veth-blue netns blue"
runthis "brctl addif virtual-bridge veth-blue-br"
echo ""

read -p "Press [Enter] key to assign IP addresses to the veth inside red and blue ns..."
runthis "ip -n red addr add local 192.168.1.2/24 dev veth-red"
runthis "ip -n blue addr add local 192.168.1.3/24 dev veth-blue"
echo ""

read -p "Press [Enter] key to bring the devices up..."
runthis "ip link set virtual-bridge up"
runthis "ip link set veth-red-br up"
runthis "ip link set veth-blue-br up"
runthis "ip -n red link set veth-red up"
runthis "ip -n blue link set veth-blue up"
runthis "ip -n red link set lo up"
runthis "ip -n blue link set lo up"

read -p "Press [Enter] key to show ip addr in red ns ..."
runthis "ip -n red addr"
echo ""

read -p "Press [Enter] key to show ip addr in blue ns ..."
runthis "ip -n blue addr"
echo ""

read -p "Press [Enter] key to show virtual-bridge ..."
runthis "brctl show virtual-bridge"
echo ""

read -p "Press [Enter] key to ping blue ns from red ns..."
runthis "ip netns exec red ping 192.168.1.3"
echo ""

read -p "Press [Enter] key to clear up..."

runthis "ip netns delete red"
runthis "ip netns delete blue"
runthis "ip link set virtual-bridge down"
runthis "brctl delbr virtual-bridge"
