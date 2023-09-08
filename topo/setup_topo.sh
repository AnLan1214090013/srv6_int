#!/bin/bash

create_topo(){
    #  (fc00:a::2/64)         (fc00:a::1/64)    (fc00:12::1/64)     (fc00:12::2/64)   ipv6
    #      veth0                  veth1             veth2                veth3
    #     [host1]------------------------[switch1]---------------------[host2]
    


    # setup namespace
    ip netns add switch1
    ip netns add host1
    ip netns add host2

    # setup veth peer
    ip link add veth0 type veth peer name veth1
    ip link add veth2 type veth peer name veth3
    ip link set veth0 netns host1
    ip link set veth1 netns switch1
    ip link set veth2 netns switch1
    ip link set veth3 netns host2

    # host1 configuraiton
    ip netns exec host1 ip link set lo up
    ip netns exec host1 ip addr add fc00:a::2/64 dev veth0
    ip netns exec host1 ip link set veth0 up

    # switch1 configuration
    ip netns exec switch1 ip link set lo up   
    ip netns exec switch1 ip addr add fc00:a::1/64 dev veth1
    ip netns exec switch1 ip addr add fc00:12::1/64 dev veth2
    ip netns exec switch1 ip link set veth1 up
    ip netns exec switch1 ip link set veth2 up

    # host2 configuraiton
    ip netns exec host2 ip link set lo up
    ip netns exec host2 ip addr add fc00:12::2/64 dev veth3
    ip netns exec host2 ip link set veth3 up

    # sysctl for switch1
    ip netns exec switch1 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec switch1 sysctl net.ipv6.conf.all.seg6_enabled=1
}

create_topo
