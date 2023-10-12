
### topology
```
  (fc00:a::1/64)         (fc00:b::1/64)    (fc00:b::2/64)          (fc00:c::1/64)    (fc00:c::2/64)         (fc00:d::1/64)       ipv6
    (08:00:00:00:01:00)   (08:00:00:00:11:00) (08:00:00:00:22:00)  (08:00:00:00:10:00) (08:00:00:00:20:00)   (08:00:00:00:02:00)     mac
          veth0               veth1(port0)       veth2(port1)             veth3(port0)   veth4(port1)                veth5
         [host1]------------------------[switch1]----------------------------------[switch2]------------------------[host2]
```

### Run the topo and send packet
1.cd to srv6_int root

2.use command `sudo python3 topo/setup_topo.py` to create network 

3.open a new term and use command `sudo python3 topo/start_s1.py` to start up switch1

3.open a new term and use command `sudo python3 topo/start_s2.py` to start up switch2

3.use command `sudo python3 topo/program_switch.py` to add tables to bmv2 simple switch

4.use command `sudo ip netns exec host1 python send.py fc00:a::1 fc00:d::1 "ppp"` to send packet from host1 to host2

### Delete the network
1.cd to srv6_int root

2.use command `sudo python3 topo/delete_network.py` to delete the network