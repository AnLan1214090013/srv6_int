
1.cd to srv6_int root

2.use command `sudo python3 topo/setup_topo.py` to create network 

3.use command `sudo python3 topo/program_switch.py` to add commands to simple switch

4.use command `sudo ip netns exec host1 python send.py fc00:a::2 fc00:12::2 "ppp"` to send packet to host2
