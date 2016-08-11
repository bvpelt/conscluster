# Conscluster
Consul cluster test

# Requirements
The following software should be installed and working
- VirtualBox (for use with docker machine)
- Docker at least 1.10.3
- docker-machine at least 0.7.0


See also 'Using Docker' page 220

https://www.safaribooksonline.com/blog/2015/11/17/fun-with-docker-swarm/ 

commands to execute

```
con01
docker run -d --name con01 -h con01 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.0.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -ui -server -client 0.0.0.0 -advertise 192.168.99.100 -bootstrap-expect 3

con02
docker run -d --name con02 -h con02 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.0.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -ui -server -client 0.0.0.0 -advertise 192.168.99.101 -join 192.168.99.100

con03
docker run -d --name con03 -h con03 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.0.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -ui -server -client 0.0.0.0 -advertise 192.168.99.102 -join 192.168.99.100


con04
docker run -d --name con04 -h con04 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.0.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -ui -server -client 0.0.0.0 -advertise 192.168.99.103 -join 192.168.99.100


docker exec -t con04 consul members

curl -X PUT http://192.168.99.100:8500/v1/kv/foo -d bar
curl http://192.168.99.100:8500/v1/kv/foo |jq -r '.[].Value' | base64 -d


app01
docker run -d --name app01 -h app01 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.0.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -ui -client 0.0.0.0 -advertise 192.168.99.104 -join 192.168.99.100

docker build -f ./Dockerfile -t python/server .

docker build -f ./Dockerfile-apache -t my/apache .

docker run -it --rm --name myapp my/apache

docker run -d --name=pythonweb -p 8081:80 python/server

curl -XPUT http://192.168.99.100:8500/v1/agent/service/register -d '{"name": "pythonweb", "address":"192.168.99.104","port": 8000}'

app02
docker run -d --name app02 -h app02 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.0.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -ui -client 0.0.0.0 -advertise 192.168.99.105 -join 192.168.99.100

docker build -f ./Dockerfile -t python/server .

```

