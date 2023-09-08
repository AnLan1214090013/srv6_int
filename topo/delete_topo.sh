#!/bin/bash

delete_topo(){
    #  (fc00:a::2/64)         (fc00:a::1/64)    (fc00:12::1/64)     (fc00:12::2/64)   ipv6
    #      veth0                  veth1             veth2                veth3
    #     [host1]------------------------[switch1]---------------------[host2]
    
    ip netns del switch1
    ip netns del host1
    ip netns del host2
}

delete_topo