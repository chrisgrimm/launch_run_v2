import subprocess
import sys
import re

cmd = sys.argv[1]
redis_port = sys.argv[2]
wandb_api_key = sys.argv[3]

if len(cmd) > 0:
    cmd = sys.argv[1]
    print('Running', cmd)
    subprocess.run(cmd, shell=True)
else:
    results = subprocess.run(f'ray start --head --port={redis_port}', stdout=subprocess.PIPE, shell=True)
    out = results.stdout.decode('UTF-8')
    cmd = re.findall(r'(ray start.+?)\n', out)[0]
    parallel_cmd = ('stty -echo; printf "Password: "; read PASS; stty echo; echo "${PASS}" | ' 
                    'parallel-ssh -O StrictHostKeyChecking=no -t -1 -P -i -I -x "-tt" -h hostsfile.txt ' 
                    f'"cd launch_run; sudo ./launch.sh git@github.com:chrisgrimm/vepi.git vepi {redis_port} {wandb_api_key} \\\"{cmd}\\\" -d "')
    subprocess.run(parallel_cmd, shell=True)
    print('Done!')
