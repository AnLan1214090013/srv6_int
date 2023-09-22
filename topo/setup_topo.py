import os, sys, json, subprocess, re, argparse, time
from time import sleep


def create_topo():
    #  (fc00:a::2/64)         (fc00:a::1/64)    (fc00:12::1/64)     (fc00:12::2/64)       ipv6
    #(08:00:00:00:01:00)   (08:00:00:00:11:00) (08:00:00:00:22:00)  (08:00:00:00:02:00)   mac
    #      veth0                  veth1             veth2                veth3
    #     [host1]------------------------[switch1]---------------------[host2]
    
    # setup namespace
    # ip netns add switch1
    subprocess.run("ip netns add host1", shell=True)
    subprocess.run("ip netns add host2", shell=True)

    # setup veth peer
    subprocess.run("ip link add veth0 type veth peer name veth1", shell=True)
    subprocess.run("ip link add veth2 type veth peer name veth3", shell=True)
    subprocess.run("ip link set veth0 netns host1", shell=True)
    # ip link set veth1 netns switch1
    # ip link set veth2 netns switch1
    subprocess.run("ip link set veth3 netns host2", shell=True)

    # host1 configuraiton
    subprocess.run("ip netns exec host1 ip link set lo up", shell=True)
    subprocess.run("ip netns exec host1 ip addr add fc00:a::2/64 dev veth0", shell=True)
    subprocess.run("ip netns exec host1 ifconfig veth0 hw ether 08:00:00:00:01:00", shell=True)
    subprocess.run("ip netns exec host1 ip link set veth0 up", shell=True)

    # switch1 configuration
    # ip netns exec switch1 ip link set lo up   
    # ip netns exec switch1 ip addr add fc00:a::1/64 dev veth1
    # ip netns exec switch1 ip addr add fc00:12::1/64 dev veth2
    # ip netns exec switch1 ifconfig veth1 hw ether 08:00:00:00:11:00
    # ip netns exec switch1 ifconfig veth2 hw ether 08:00:00:00:22:00
    # ip netns exec switch1 ip link set veth1 up
    # ip netns exec switch1 ip link set veth2 up


    subprocess.run("ip addr add fc00:a::1/64 dev veth1", shell=True)
    subprocess.run("ip addr add fc00:12::1/64 dev veth2", shell=True)
    subprocess.run("ifconfig veth1 hw ether 08:00:00:00:11:00", shell=True)
    subprocess.run("ifconfig veth2 hw ether 08:00:00:00:22:00", shell=True)
    subprocess.run("ip link set veth1 up", shell=True)
    subprocess.run("ip link set veth2 up", shell=True)

    # host2 configuraiton
    subprocess.run("ip netns exec host2 ip link set lo up", shell=True)
    subprocess.run("ip netns exec host2 ip addr add fc00:12::2/64 dev veth3", shell=True)
    subprocess.run("ip netns exec host2 ifconfig veth3 hw ether 08:00:00:00:02:00", shell=True)
    subprocess.run("ip netns exec host2 ip link set veth3 up", shell=True)

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

def start_switch():
    switch_port = 8001
    print("start switch on port "+str(switch_port))
    # simple_switch --interface 0@veth1 --interface 1@veth2 p4_src/build/int.json &
    # simple_switch p4_src/build/int.json --interface 0@veth1 --interface 1@veth2  --nanolog ipc:///tmp/bm-o-log.ipc
    os.system("simple_switch --thrift-port "+str(switch_port)+" --log-file bmlog --log-flush -i 0@veth1 -i 1@veth2 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/int.json")
    # simple_switch --thrift-port 8099 --log-console -i 0@veth1 -i 1@veth2 --nanolog ipc:///tmp/bm-log.ipc p4_src/build/int.json

    # add tables to switch
def program_switches():   
    switch_port = 8001
    cli = 'simple_switch_CLI'
    with open('tables/s1-commands.txt', 'r') as fin:
        lines = fin.readlines()
        for line in lines:
            print("add command: "+line)
    with open('tables/s1-commands.txt', 'r') as fin:
        cli_outfile = 'topo/s1_cli_output.log'
        with open(cli_outfile, 'a') as fout:
             subprocess.Popen([cli, '--thrift-port', str(switch_port)], stdin=fin, stdout=fout)




    # def program_switches(self):
    #     """ If any command files were provided for the switches,
    #         this method will start up the CLI on each switch and use the
    #         contents of the command files as input.

    #         Assumes:
    #             - A mininet instance is stored as self.net and self.net.start() has
    #               been called.
    #     """
    #     cli = 'simple_switch_CLI'
    #     for sw_name, sw_dict in self.switches.items():
    #         if 'cli_input' not in sw_dict: continue
            
    #         # get the port for this particular switch's thrift server
    #         sw_obj = self.net.get(sw_name)
            
    #         thrift_port = sw_obj.thrift_port
    #         print('swname: ',sw_name,' sw_thrift_port ',thrift_port)
    #         cli_input_commands = sw_dict['cli_input']
    #         self.logger('Configuring switch %s with file %s' % (sw_name, cli_input_commands))
    #         with open(cli_input_commands, 'r') as fin:
    #             cli_outfile = '%s/%s_cli_output.log'%(self.log_dir, sw_name)
    #             with open(cli_outfile, 'w') as fout:
    #                 subprocess.Popen([cli, '--thrift-port', str(thrift_port)],
    #                                  stdin=fin, stdout=fout)

if __name__ == '__main__':
    create_topo()
    start_switch()
    # sleep(1)
    # program_switches()