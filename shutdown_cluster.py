from pssh.clients import ParallelSSHClient
import os
import subprocess

head = bool(os.environ['IS_HEAD'])
name = os.environ['CONTAINER_NAME']
password = os.environ['PASSWORD']
user = 'crgrimm'  # TODO fix this

if not head:
    exit()

with open('/app/hostsfile.txt', 'r') as f:
    hosts = [x.strip() for x in f.readlines()]
    hosts = [x for x in hosts if not x.startswith('#')]

client = ParallelSSHClient(hosts, user=user, pkey='/root/.ssh/id_rsa')
cmd = f'echo "{password}" | sudo -S docker container stop {name}'
print('Shutting down nodes...')
conns = client.run_command(cmd)
print(list(conns[0].stderr))
print(list(conns[0].stdout))
