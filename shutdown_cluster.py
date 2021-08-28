from pssh.clients import ParallelSSHClient
import sys
import subprocess

name = sys.environ['CONTAINER_NAME']
password = sys.environ['PASSWORD']
user = 'crgrimm'  # TODO fix this

with open('/app/hostsfile.txt', 'r') as f:
    hosts = [x.strip() for x in f.readlines()]
    hosts = [x for x in hosts if not x.startswith('#')]

client = ParallelSSHClient(hosts, user=user, pkey='/root/.ssh/id_rsa')
conns = client.run_command(
    f'echo "{password}" | sudo -S docker container stop {name}')

