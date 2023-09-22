import subprocess, os

def destory_network():
    switch_port = 8001
    subprocess.run("ip netns del switch1", shell=True)
    subprocess.run("ip netns del host1", shell=True)
    subprocess.run("ip netns del host2", shell=True)
    subprocess.run("ip link delete veth0", shell=True)
    subprocess.run("ip link delete veth1", shell=True)
    subprocess.run("ip link delete veth2", shell=True)
    subprocess.run("ip link delete veth3", shell=True)
    killport(switch_port)

def remove_logs():
    subprocess.run("rm /tmp/bmv2-0-notifications.ipc", shell=True)
    subprocess.run("rm /tmp/bm-log.ipc", shell=True)
    subprocess.run("rm ./bmlog.txt", shell=True)

def killport(port):
    command="kill -9 $(netstat -nlp | grep :"+str(port)+" | awk '{print $7}' | awk -F'/' '{{ print $1 }}')"
    os.system(command)

if __name__ == '__main__':
    destory_network()
    remove_logs()