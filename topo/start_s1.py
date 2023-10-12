import os, sys, json, subprocess, re, argparse, time
from time import sleep

def start_switch():
    # s1 startup
    switch_port = 8001
    print("start switch1 on port "+str(switch_port))
    os.system("simple_switch --thrift-port "+str(switch_port)+" --log-file s1_log --log-flush -i 0@veth1 -i 1@veth2 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/srv6_int.json")

if __name__ == '__main__':
    start_switch()