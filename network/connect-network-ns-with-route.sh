#!/bin/bash

runthis(){
    ## print the command to the logfile
    echo "$@" 
    ## run the command and redirect it's error output
    ## to the logfile
    eval "$@" 
}

echo ""
echo "This experiment shows how to connect two namespaces through a router(Linux OS)"
echo ""

read -p "Press [Enter] key to create networkspaces..."
runthis "ip netns add ns1"
runthis "ip netns add ns2"
echo ""
runthis "ip netns"
echo ""

read -p "Press [Enter] key to link ns1 to the router..."
runthis "ip link add veth-ns1 type veth peer name veth-ns1-peer"
runthis "ip link set veth-ns1 netns ns1"
echo ""

read -p "Press [Enter] key to link ns2 to router..."
runthis "ip link add veth-ns2 type veth peer name veth-ns2-peer"
runthis "ip link set veth-ns2 netns ns2"
echo ""

read -p "Press [Enter] key to assign IP addresses to the devieces..."
runthis "ip -n ns1 addr add 192.168.1.2/24 dev veth-ns1"
runthis "ip -n ns2 addr add 192.168.2.2/24 dev veth-ns2"
runthis "ip addr add 192.168.1.1/24 dev veth-ns1-peer"
runthis "ip addr add 192.168.2.1/24 dev veth-ns2-peer"
echo ""

echo "Bring up the devieces..."
runthis "ip -n ns1 link set veth-ns1 up"
runthis "ip -n ns2 link set veth-ns2 up"
runthis "ip link set veth-ns1-peer up"
runthis "ip link set veth-ns2-peer up"
echo ""

read -p "Press [Enter] key to show ip addr..."
runthis "ip -n ns1 addr"
echo ""

runthis "ip -n ns2 addr"
echo ""

runthis "ip addr"
echo ""

read -p "Press [Enter] key to ping ns2 ns from ns1, ns1 can't reach ns2 because they're in different subnetworks..."
runthis "ip netns exec ns1 ping 192.168.2.2"
echo ""

read -p "Press [Enter] key to add routes..."
runthis "ip netns exec ns1 ip route add 192.168.2.0/24 via 192.168.1.1"
runthis "ip netns exec ns2 ip route add 192.168.1.0/24 via 192.168.2.1"

read -p "Now the two namespaces should be able to reach to each other through the 'router'(Linux OS itself)..."
runthis "ip netns exec ns1 ping 192.168.2.2"
runthis "ip netns exec ns2 ping 192.168.1.2"
echo ""

read -p "Press [Enter] key to clear up..."

runthis "ip netns delete ns1"
runthis "ip netns delete ns2"
