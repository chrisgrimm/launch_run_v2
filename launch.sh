#(1) name (2) redis_port (3) user

function cleanup () 
{
    stty echo
    printf "\n"
    exit 2
}

trap "cleanup" 2

stty -echo
printf "Password: "
read password
stty echo
echo "$password" | sudo -S ./spin_up_docker.sh $1 "$password"
echo "$password" | sudo -S docker exec $1 python3.8 -u ./launch_cluster.py "$1" "$2" "$3" "$password"
