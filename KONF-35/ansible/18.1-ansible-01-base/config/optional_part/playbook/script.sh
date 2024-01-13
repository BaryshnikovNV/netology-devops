#!/bin/bash

host_c=centos7
host_u=ubuntu
host_f=fedora

image_c=pycontribs/centos:7
image_u=pycontribs/ubuntu:latest
image_f=pycontribs/fedora:latest

docker run -d --name $host_c $image_c sleep infinity
docker run -d --name $host_u $image_u sleep infinity
docker run -d --name $host_f $image_f sleep infinity

ansible-playbook -i inventory/prod.yml site.yml --ask-vault-password

docker stop $host_c $host_u $host_f
docker rm $host_c $host_u $host_f