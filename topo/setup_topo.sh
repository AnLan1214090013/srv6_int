#!/bin/bash

create_topo(){
    #  (fc00:a::2/64)         (fc00:a::1/64)    (fc00:12::1/64)     (fc00:12::2/64)       ipv6
    #(08:00:00:00:01:00)   (08:00:00:00:11:00) (08:00:00:00:22:00)  (08:00:00:00:02:00)   mac
    #      veth0                  veth1             veth2                veth3
    #     [host1]------------------------[switch1]---------------------[host2]
    


    # setup namespace
    # ip netns add switch1
    ip netns add host1
    ip netns add host2

    # setup veth peer
    ip link add veth0 type veth peer name veth1
    ip link add veth2 type veth peer name veth3
    ip link set veth0 netns host1
    # ip link set veth1 netns switch1
    # ip link set veth2 netns switch1
    ip link set veth3 netns host2

    # host1 configuraiton
    ip netns exec host1 ip link set lo up
    ip netns exec host1 ip addr add fc00:a::2/64 dev veth0
    ip netns exec host1 ifconfig veth0 hw ether 08:00:00:00:01:00
    ip netns exec host1 ip link set veth0 up

    # switch1 configuration
    # ip netns exec switch1 ip link set lo up   
    # ip netns exec switch1 ip addr add fc00:a::1/64 dev veth1
    # ip netns exec switch1 ip addr add fc00:12::1/64 dev veth2
    # ip netns exec switch1 ifconfig veth1 hw ether 08:00:00:00:11:00
    # ip netns exec switch1 ifconfig veth2 hw ether 08:00:00:00:22:00
    # ip netns exec switch1 ip link set veth1 up
    # ip netns exec switch1 ip link set veth2 up


    ip addr add fc00:a::1/64 dev veth1
    ip addr add fc00:12::1/64 dev veth2
    ifconfig veth1 hw ether 08:00:00:00:11:00
    ifconfig veth2 hw ether 08:00:00:00:22:00
    ip link set veth1 up
    ip link set veth2 up

    # host2 configuraiton
    ip netns exec host2 ip link set lo up
    ip netns exec host2 ip addr add fc00:12::2/64 dev veth3
    ip netns exec host2 ifconfig veth3 hw ether 08:00:00:00:02:00
    ip netns exec host2 ip link set veth3 up

    # #add route host1
    # ip netns exec host1 ip -6 route add fc00:12::/64 via fc00:a::1
    # #add route host2
    # ip netns exec host2 ip -6 route add fc00:a::/64 via fc00:12::1


    # sysctl for all dev
    sysctl net.ipv6.conf.all.seg6_enabled=1
    sysctl net.ipv6.conf.all.forwarding=1
    # ip netns exec switch1 sysctl net.ipv6.conf.all.forwarding=1
    # ip netns exec switch1 sysctl net.ipv6.conf.all.seg6_enabled=1
    ip netns exec host1 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec host1 sysctl net.ipv6.conf.all.seg6_enabled=1
    ip netns exec host2 sysctl net.ipv6.conf.all.forwarding=1
    ip netns exec host2 sysctl net.ipv6.conf.all.seg6_enabled=1
    
}

SWITCH_PORT=8103

start_switch(){
    echo "start switch on port ${SWITCH_PORT}"
    # simple_switch --interface 0@veth1 --interface 1@veth2 p4_src/build/int.json &
    # simple_switch p4_src/build/int.json --interface 0@veth1 --interface 1@veth2  --nanolog ipc:///tmp/bm-o-log.ipc
    simple_switch --thrift-port ${SWITCH_PORT} --log-file bmlog --log-flush -i 0@veth1 -i 1@veth2 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/int.json
    # simple_switch --thrift-port 8099 --log-console -i 0@veth1 -i 1@veth2 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/int.json
    simple_switch_CLI --thrift-port ${SWITCH_PORT} -x bash -c "table_add srv6_ingress.local_mac_table NoAction 08:00:00:00:11:00 => "
}

create_topo
start_switch
