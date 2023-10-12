import os, sys, json, subprocess, re, argparse, time
from time import sleep


def create_topo():
    #  (fc00:a::1/64)         (fc00:b::1/64)    (fc00:b::2/64)          (fc00:c::1/64)    (fc00:c::2/64)         (fc00:d::1/64)       ipv6
    #(08:00:00:00:01:00)   (08:00:00:00:11:00) (08:00:00:00:22:00)  (08:00:00:00:10:00) (08:00:00:00:20:00)   (08:00:00:00:02:00)     mac
    #      veth0               veth1(port0)       veth2(port1)             veth3(port0)   veth4(port1)                veth5
    #     [host1]------------------------[switch1]----------------------------------[switch2]------------------------[host2]
    
    # setup namespace
    # ip netns add switch1
    subprocess.run("ip netns add host1", shell=True)
    subprocess.run("ip netns add host2", shell=True)

    # setup veth peer
    subprocess.run("ip link add veth0 type veth peer name veth1", shell=True)
    subprocess.run("ip link add veth2 type veth peer name veth3", shell=True)
    subprocess.run("ip link add veth4 type veth peer name veth5", shell=True)
    subprocess.run("ip link set veth0 netns host1", shell=True)
    # ip link set veth1 netns switch1
    # ip link set veth2 netns switch1
    subprocess.run("ip link set veth5 netns host2", shell=True)

    # host1 configuraiton
    subprocess.run("ip netns exec host1 ip link set lo up", shell=True)
    subprocess.run("ip netns exec host1 ip addr add fc00:a::1/64 dev veth0", shell=True)
    subprocess.run("ip netns exec host1 ifconfig veth0 hw ether 08:00:00:00:01:00", shell=True)
    subprocess.run("ip netns exec host1 ip link set veth0 up", shell=True)

    # switch1 configuration
    subprocess.run("ip addr add fc00:b::1/64 dev veth1", shell=True)
    subprocess.run("ip addr add fc00:b::2/64 dev veth2", shell=True)
    subprocess.run("ifconfig veth1 hw ether 08:00:00:00:11:00", shell=True)
    subprocess.run("ifconfig veth2 hw ether 08:00:00:00:22:00", shell=True)
    subprocess.run("ip link set veth1 up", shell=True)
    subprocess.run("ip link set veth2 up", shell=True)

    # switch2 configuration
    subprocess.run("ip addr add fc00:c::1/64 dev veth3", shell=True)
    subprocess.run("ip addr add fc00:c::2/64 dev veth4", shell=True)
    subprocess.run("ifconfig veth3 hw ether 08:00:00:00:10:00", shell=True)
    subprocess.run("ifconfig veth4 hw ether 08:00:00:00:20:00", shell=True)
    subprocess.run("ip link set veth3 up", shell=True)
    subprocess.run("ip link set veth4 up", shell=True)

    # host2 configuraiton
    subprocess.run("ip netns exec host2 ip link set lo up", shell=True)
    subprocess.run("ip netns exec host2 ip addr add fc00:d::1/64 dev veth5", shell=True)
    subprocess.run("ip netns exec host2 ifconfig veth5 hw ether 08:00:00:00:02:00", shell=True)
    subprocess.run("ip netns exec host2 ip link set veth5 up", shell=True)

    # #add route host1
    # ip netns exec host1 ip -6 route add fc00:12::/64 via fc00:a::1
    # #add route host2
    # ip netns exec host2 ip -6 route add fc00:a::/64 via fc00:12::1


    # sysctl for all dev
    subprocess.run("sysctl net.ipv6.conf.all.seg6_enabled=1", shell=True)
    subprocess.run("sysctl net.ipv6.conf.all.forwarding=1", shell=True)
    # ip netns exec switch1 sysctl net.ipv6.conf.all.forwarding=1
    # ip netns exec switch1 sysctl net.ipv6.conf.all.seg6_enabled=1
    subprocess.run("ip netns exec host1 sysctl net.ipv6.conf.all.forwarding=1", shell=True)
    subprocess.run("ip netns exec host1 sysctl net.ipv6.conf.all.seg6_enabled=1", shell=True)
    subprocess.run("ip netns exec host2 sysctl net.ipv6.conf.all.forwarding=1", shell=True)
    subprocess.run("ip netns exec host2 sysctl net.ipv6.conf.all.seg6_enabled=1", shell=True)

# def start_switch():
    
#     # simple_switch --interface 0@veth1 --interface 1@veth2 p4_src/build/int.json &
#     # simple_switch p4_src/build/int.json --interface 0@veth1 --interface 1@veth2  --nanolog ipc:///tmp/bm-o-log.ipc

#     # s1 startup
#     switch_port = 8001
#     print("start switch1 on port "+str(switch_port))
#     os.system("simple_switch --thrift-port "+str(switch_port)+" --log-file s1_log --log-flush -i 0@veth1 -i 1@veth2 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/srv6_int.json")
#     # s2 startup
#     switch_port2 = 8002
#     print("start switch2 on port "+str(switch_port2))
#     os.system("simple_switch --thrift-port "+str(switch_port2)+" --log-file s2_log --log-flush -i 0@veth3 -i 1@veth4 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/srv6_int.json")

if __name__ == '__main__':
    create_topo()
    # start_switch()
    # sleep(1)
    # program_switches()