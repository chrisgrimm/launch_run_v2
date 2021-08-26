from pssh.clients import ParallelSSHClient
from pssh.exceptions import Timeout
import sys
import re
import subprocess
import tqdm

print('Launching...')

name = sys.argv[1]
redis_port = sys.argv[2]
user = sys.argv[3]
password = sys.argv[4]

# launch the head instance
results = subprocess.run(f'ray start --head --port={redis_port}', stdout=subprocess.PIPE, shell=True)
out = results.stdout.decode('UTF-8')
ray_cmd = re.findall(r'(ray start.+?)\n', out)[0]

# read host file
with open('/app/hostsfile.txt', 'r') as f:
    hosts = [x.strip() for x in f.readlines()]
    hosts = [x for x in hosts if not x.startswith('#')]

print('Found hosts', hosts)

client = ParallelSSHClient(hosts, user=user, pkey='/root/.ssh/id_rsa')
conns = client.run_command(
    f'cd launch_run_v2 && echo "{password}" | sudo -S ./spin_up_docker.sh "{name}"',
    read_timeout=0.1)

# wait for hosts to spin up
print('Waiting for containers to be built...')

finished = {host: False for host in hosts}
denom = 34
bars = {host: tqdm.tqdm(total=denom, desc=host, position=i) for i, host in enumerate(hosts)}

while not all(finished[host] for host in hosts):
    for host, con in zip(hosts, conns):
        num_steps = 0
        try:
            for line in con.stdout:
                num_steps += len(re.findall(r'^Step (\d+\/\d+)', line))
            finished[host] = True
        except Timeout:
            pass
        finally:
            bars[host].update(num_steps)

        
        
for host, con in zip(hosts, conns):
    if con.exit_code != 0:
        print(f'({host}) Error', list(con.stderr))

print('Sending ray node commands')
conns = client.run_command(f'echo "{password}" | sudo -S docker exec -d "{name}" {ray_cmd}')
for con in conns:
    list(con.stdout)
