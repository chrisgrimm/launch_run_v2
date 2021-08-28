from pssh.clients import ParallelSSHClient
import sys

setup_script = sys.argv[1]
user = 'crgrimm'

with open('/app/hostsfile.txt', 'r') as f:
    hosts = [x.strip() for x in f.readlines()]
    hosts = [x for x in hosts if not x.startswith('#')]

client = ParallelSSHClient(hosts, user=user, pkey='/root/.ssh/id_rsa')
conns = client.run_command(f'sh {setup_script}')
