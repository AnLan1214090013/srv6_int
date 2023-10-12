import os, sys, json, subprocess, re, argparse, time
from time import sleep

def start_switch():
    # s2 startup
    switch_port = 7001
    print("start switch2 on port "+str(switch_port))
    os.system("simple_switch --thrift-port "+str(switch_port)+" --log-file s2_log --log-flush -i 0@veth3 -i 1@veth4 --nanolog ipc:///tmp/bm-log-s2.ipc --notifications-addr ipc:///tmp/bmv2-s2-notifications.ipc p4_src/build/srv6_int.json")

if __name__ == '__main__':
    start_switch()