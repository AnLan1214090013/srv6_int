import os, sys, json, subprocess, re, argparse, time
from time import sleep
switch_port = 8001
def program_switches():   
    cli = 'simple_switch_CLI'
    with open('tables/s1-commands.txt', 'r') as fin:
        lines = fin.readlines()
        for line in lines:
            print("add command: "+line)
    with open('tables/s1-commands.txt', 'r') as fin:
        cli_outfile = 'topo/s1_cli_output.log'
        with open(cli_outfile, 'a') as fout:
             subprocess.Popen([cli, '--thrift-port', str(switch_port)], stdin=fin, stdout=fout)

if __name__ == '__main__':
    program_switches()