# (1) name (2) redis port
prv_key=$(cat ~/.ssh/id_rsa)
pub_key=$(cat ~/.ssh/id_rsa.pub)
#sudo docker system prune -af && \ 
sudo docker build -t ray-docker2 \
--build-arg name="$1" \
--build-arg ssh_prv_key="$prv_key" \
--build-arg ssh_pub_key="$pub_key" \
--build-arg redis_port=$2 \
--build-arg uid="$(id -u)" \
--build-arg gid="$(id -g)" . && \
sudo docker run --name $1 --gpus=all --net=host -it --shm-size=8gb --mount type=bind,source="/shared",target="/shared" ray-docker2
