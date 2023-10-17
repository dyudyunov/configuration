#!/bin/sh
# 6 6 * * 1 nice /root/docker-clean.sh > /dev/null 2>&1
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker volume rm $(docker volume ls -f dangling=true -q)
docker volume ls -qf dangling=true | xargs -r docker volume rm
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
