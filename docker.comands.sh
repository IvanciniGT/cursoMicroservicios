    1  whoami
    2  pwd
    3  ls
    4  ls
    5  docker --version
    6  which ls
    7  ls --version
    8  cd ..
    9  cd environment/
   10  which cd
   11  cd --version
   12  ls /bin
   13  mkdir --version
   14  clear
   15  docker --version
   16  docker version
   17  systemctl status docker
   18  docker version
   19  docker image ls
   20  docker images
   21  docker container list
   22  docker ps
   23  docker container list -a
   24  docker image pull nginx:1.27.1
   25  docker image ls
   26  docker container create nginx:1.27.1
   27  docker container ls
   28  docker container ls -a
   29  docker container rm cool_kapitsa
   30  docker container ls -a
   31  docker container create --name minginx nginx:1.27.1
   32  docker container ls -a
   33  docker container start minginx
   34  docker container ls
   35  docker image inspect nginx:1.27.1
   36  clear
   37  docker container ls
   38  curl http://localhost:80
   39  systemctl status apache2
   40  sudo systemctl stop apache2
   41  curl http://localhost:80
   42  docker container ls
   43  docker container inspect minginx
   44  curl http://172.17.0.2:80
   45  docker container stop minginx
   46  curl http://172.17.0.2:80
   47  docker container start minginx
   48  curl http://172.17.0.2:80
   49  docker container ls
   50  docker container stop minginx
   51  docker container rm minginx
   52  docker container list -a
   53  docker container create --name minginx nginx:1.27.1
   54  docker container create --name minginx2 nginx:1.27.1
   55  docker container create --name minginx3 nginx:1.27.1
   56  docker container start minginx
   57  docker container start minginx2
   58  docker container start minginx3
   59  docker logs minginx3
   60  docker logs minginx1
   61* 
   62  docker contaqiner stop minginx
   63  docker container stop minginx
   64  docker logs minginx
   65  docker container start minginx
   66  ps -eaf --forest
   67  docker exec minginx sleep 3600
   68  docker exec minginx ls /
   69  docker exec minginx ls -l /
   70  docker exec -it minginx bash
   71  docker exec minginx ls --version
   72  docker exec minginx ls /usr/bin/ls
   73  docker exec minginx ls -l /usr/bin/ls
   74  docker exec -it minginx bash
   75  docker exec minginx ps
   76  docker exec -it minginx bash
   77  docker container list -a
   78  history > history.sh
