from pssh.clients import ParallelSSHClient
import sys
import subprocess

setup_script = sys.argv[1]
user = 'crgrimm'

with open('/app/hostsfile.txt', 'r') as f:
    hosts = [x.strip() for x in f.readlines()]
    hosts = [x for x in hosts if not x.startswith('#')]

client = ParallelSSHClient(hosts, user=user, pkey='/root/.ssh/id_rsa')
subprocess.run(f'sh {setup_script}')
conns = client.run_command(f'sh {setup_script}')
