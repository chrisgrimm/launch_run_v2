# (1) name  (2) password (3) is_head
prv_key=$(cat ~/.ssh/id_rsa)
pub_key=$(cat ~/.ssh/id_rsa.pub)
sudo docker container stop $1
sudo docker container rm $1
sudo docker system prune -af 
sudo docker build -t ray-docker2 --no-cache \
--build-arg is_head="$3" \ 
--build-arg name="$1" \
--build-arg ssh_prv_key="$prv_key" \
--build-arg ssh_pub_key="$pub_key" \
--build-arg uid="$(id -u)" \
--build-arg password="$2" \
--build-arg gid="$(id -g)" . && \
sudo docker run --rm --name $1 -dit --gpus=all --net=host --shm-size=8gb --mount type=bind,source="/shared",target="/shared" ray-docker2
