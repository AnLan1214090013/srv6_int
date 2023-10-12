#!/usr/bin/env python
import argparse
import sys
import socket
import random
import struct

# from scapy.all import sendp, send, get_if_list, get_if_hwaddr
# from scapy.all import Packet
# from scapy.all import Ether, IP, UDP, TCP
from scapy.all import *
from time import sleep


class InBandNetworkTelemetry(Packet):
    fields_desc = [ BitField("switchID_t", 0, 31),
                    BitField("ingress_port",0, 9),
                    BitField("egress_port",0, 9),
                    BitField("egress_spec", 0, 9),
                    BitField("ingress_global_timestamp", 0, 48),
                    BitField("egress_global_timestamp", 0, 48),
                    BitField("enq_timestamp",0, 32),
                    BitField("enq_qdepth",0, 19),
                    BitField("deq_timedelta", 0, 32),
                    BitField("deq_qdepth", 0, 19)
                  ]
    def extract_padding(self, p):
                return "", p

class nodeCount(Packet):
  name = "nodeCount"
  fields_desc = [ ShortField("count", 0),
                  PacketListField("INT", [], InBandNetworkTelemetry, count_from=lambda pkt:(pkt.count*1))]



def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print('Cannot find eth0 interface')
        exit(1)
    return iface

def main():

    if len(sys.argv)<3:
        print('pass 2 arguments: <destination> "<message>"')
        exit(1)

    print(sys.argv[1])
    # addr = socket.gethostbyname(sys.argv[1])
    addr = sys.argv[2]
    saddr = sys.argv[1]
    iface = get_if()

    print('sending on interface %s to %s' % (iface, str(addr)))
    # pkt =  Ether(src=get_if_hwaddr(iface), dst='ff:ff:ff:ff:ff:ff')saddr
    # pkt = pkt /IP(dst=addr) / TCP(dport=1234, sport=27777) / sys.argv[2]
    # pkt =  Ether(src=get_if_hwaddr(iface), dst='08:00:00:00:11:00') / IPv6(src=saddr,dst=addr) / UDP(dport=4321, sport=1234) / sys.argv[3]
    # bind_layers(IP, nodeCount, proto = 253)
    bind_layers(IPv6ExtHdrSegmentRouting, nodeCount, proto = 253)
    pkt =  Ether(src=get_if_hwaddr(iface), dst='08:00:00:00:11:00') / IPv6(src=saddr,dst=addr) / IPv6ExtHdrSegmentRouting(addresses = ["fc00:c::2","fc00:b::2"], nh = 253) / nodeCount(count = 0, INT=[]) / sys.argv[3]
    pkt.show2()
    
    sendp(pkt, iface=iface, verbose=False)


if __name__ == '__main__':
    main()
