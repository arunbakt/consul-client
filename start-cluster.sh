#!/bin/bash
# This is for running local consul servers and client to test the key value pushes

eval $(docker-machine env consul-node)
docker run --rm=true --name consul-server1 -h consul-server1  -p 8300:8300 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8301:8301 -p 192.168.99.100:8500:8500 -p 8400:8400 -p 53:8600/udp  gliderlabs/consul agent -server -http-port=8500 -advertise=192.168.99.100 --bootstrap-expect 2 -data-dir /tmp/consul-server &

eval $(docker-machine env consul-node-2)
docker run --rm=true --name consul-server2 -h consul-server2  -p 8300:8300 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8301:8301 -p 8500:8500 -p 8400:8400 -p 53:8600/udp  gliderlabs/consul agent -server -advertise=192.168.99.101 -join=192.168.99.100 -data-dir /tmp/consul2 & 

eval $(docker-machine env consul-client)
docker run --rm=true --name consul-client -h consul-client  -p 8300:8300 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8301:8301 -p 8500:8500 -p 8400:8400 -p 53:8600/udp  arunbakt/consul-client agent -ui -data-dir=/tmp/consul-client -join=192.168.99.101 --advertise=192.168.99.102 -client=0.0.0.0 &
