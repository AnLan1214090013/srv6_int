#!/bin/bash

delete_topo(){
    #  (fc00:a::2/64)         (fc00:a::1/64)    (fc00:12::1/64)     (fc00:12::2/64)   ipv6
    #      veth0                  veth1             veth2                veth3
    #     [host1]------------------------[switch1]---------------------[host2]
    
    ip netns del switch1
    ip netns del host1
    ip netns del host2
    ip link delete veth0
    ip link delete veth1
    ip link delete veth2
    ip link delete veth3
    rm /tmp/bmv2-0-notifications.ipc
    rm /tmp/bm-log.ipc
    rm ./bmlog.txt
}

delete_topo

# for idx in 0 1 2 3; do
#     intf="veth$(($idx*2))"
#     if ip link show $intf &> /dev/null; then
#         ip link delete $intf type veth
#     fi
# done