import subprocess, sys

redis_port = sys.argv[1]
result = subprocess.run(f'ray start --head --port={redis_port}', stdout=subprocess.PIPE, shell=True)
