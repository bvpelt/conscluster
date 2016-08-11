#!/bin/bash 

# number virtual machines for consul server
numcon=4

# number virtual machines for applications
numapp=2

function clearenv {
		echo clear docker environment
		unset DOCKER_HOST
		unset DOCKER_MACHINE_NAME
		unset DOCKER_TLS_VERIFY
		unset DOCKER_CERT_PATH
}

#
# Create number app server machines
#
function createappserver {
	echo "createappserver -a01"
	for i in $(seq 1 $numapp)
	do
		appexist=`docker-machine ls | grep "^app0$i" | wc -l`
#		echo conexist: $conexist

		if [ "1" = "$appexist" ]
	    then
			echo machine app0$i exists
		else
			echo machine app0$i doesnot exists, == creating ==
			docker-machine create -d virtualbox app0$i
			# Set consul ports	
			#VBoxManage modifyvm "con0$i" --natpf1 delete tmi
			#VBoxManage modifyvm "con0$i" --natpf1 "con01,tcp,,8300,,8300"
			#VBoxManage modifyvm "con0$i" --natpf1 "con02,tcp,,8301,,8301"
			#VBoxManage modifyvm "con0$i" --natpf1 "con03,udp,,8301,,8301"
			#VBoxManage modifyvm "con0$i" --natpf1 "con04,tcp,,8302,,8302"
			#VBoxManage modifyvm "con0$i" --natpf1 "con05,udp,,8302,,8302"
			#VBoxManage modifyvm "con0$i" --natpf1 "con06,tcp,,8400,,8400"
			#VBoxManage modifyvm "con0$i" --natpf1 "con07,tcp,,8500,,8500"
			#VBoxManage modifyvm "con0$i" --natpf1 "con08,udp,,8500,,8500"
			#VBoxManage modifyvm "con0$i" --natpf1 "con09,tcp,,8600,,8600"
			#VBoxManage modifyvm "con0$i" --natpf1 "con10,udp,,8600,,8600"
		fi
	done
}

#
# Create number consul server machines
#
function createserver {
	echo "createserver -c01"
	for i in $(seq 1 $numcon)
	do
		conexist=`docker-machine ls | grep "^con0$i" | wc -l`
#		echo conexist: $conexist

		if [ "1" = "$conexist" ]
	    then
			echo machine con0$i exists
		else
			echo machine con0$i doesnot exists, == creating ==
			docker-machine create -d virtualbox con0$i			
			# Set consul ports
			#VBoxManage modifyvm "con0$i" --natpf1 delete tmi
			#VBoxManage modifyvm "con0$i" --natpf1 "con01,tcp,,8300,,8300"
			#VBoxManage modifyvm "con0$i" --natpf1 "con02,tcp,,8301,,8301"
			#VBoxManage modifyvm "con0$i" --natpf1 "con03,udp,,8301,,8301"
			#VBoxManage modifyvm "con0$i" --natpf1 "con04,tcp,,8302,,8302"
			#VBoxManage modifyvm "con0$i" --natpf1 "con05,udp,,8302,,8302"
			#VBoxManage modifyvm "con0$i" --natpf1 "con06,tcp,,8400,,8400"
			#VBoxManage modifyvm "con0$i" --natpf1 "con07,tcp,,8500,,8500"
			#VBoxManage modifyvm "con0$i" --natpf1 "con08,udp,,8500,,8500"
			#VBoxManage modifyvm "con0$i" --natpf1 "con09,tcp,,8600,,8600"
			#VBoxManage modifyvm "con0$i" --natpf1 "con10,udp,,8600,,8600"

		fi
	done
}


#
# Start consul app machines, after each stop
#
function startappmachine {
	echo "startappmachine -a02"
	echo startappmachine
	for i in $(seq 1 $numapp)
	do
		appexist=`docker-machine ls | grep "^app0$i" | wc -l`
#		echo appexist: $appexist

		if [ "1" = "$appexist" ]
	    then
			echo machine app0$i exists
			docker-machine start app0$i
		else
			echo "machine app0$i doesnot exists, can't start"
		fi
	done
}


#
# Start consul server machines, after each stop
#
function startservermachine {
	echo "startservermachine -c02"
	echo startservermachine
	for i in $(seq 1 $numcon)
	do
		conexist=`docker-machine ls | grep "^con0$i" | wc -l`
#		echo conexist: $conexist

		if [ "1" = "$conexist" ]
	    then
			echo machine con0$i exists
			docker-machine start con0$i
		else
			echo "machine con0$i doesnot exists, can't start"
		fi
	done
}


#
# Install applications, without starting docker images
#
# - consul agent
# - registrator
# - webservice (example)
#
function installapp {
	echo "installapp -a03"
	for i in $(seq 1 $numapp)
	do
		appexist=`docker-machine ls | grep "^app0$i" | wc -l`		

		if [ "1" = "$appexist" ]
	    then
	    	echo machine app0$i exists, == installing ==
			eval "$(docker-machine env app0$i)"
			
			docker pull consul

			docker pull gliderlabs/registrator

			echo Build docker image for webservice
			# Build python image using Dockerfile from current directory
			docker build -f ./Dockerfile -t python/server .

			clearenv
		else			
			echo machine app0$i doesnot exists			
		fi
	done
}

#
# Install consul server, without starting docker services
#
function installserver {
	echo "installserver -c03"
	for i in $(seq 1 $numcon)
	do
		conexist=`docker-machine ls | grep "^con0$i" | wc -l`		

		if [ "1" = "$conexist" ]
	    then
	    	echo machine con0$i exists, == installing ==
			eval "$(docker-machine env con0$i)"
			printenv | grep -i docker
			docker pull consul

			clearenv
		else			
			echo machine con0$i doesnot exists			
		fi
	done
}


#
# Start app images, only the first time
#
function startappservice {
	echo "startappservice -a04"
	maxexpect=$(($numapp -1))
	echo maxexpect: $maxexpect

	eval "$(docker-machine env con01)"
	masteripaddr=`docker-machine ip con01`

	for i in $(seq 1 $numapp)
	do
		appexist=`docker-machine ls | grep "^app0$i" | wc -l`		

		if [ "1" = "$appexist" ]
	    then

	    	# Start docker consul agent
	    	echo machine app0$i exists, == starting ==
	    	
			eval "$(docker-machine env app0$i)"
	        ipaddr=`docker-machine ip app0$i`
			echo app0$i addr: $ipaddr
			
			# Start consul agent
			echo "docker run -d --name=app0$i --net=host -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -bind=$ipaddr -retry-join=$masteripaddr"

			# docker run -d --name=app0$i -h app0$i -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.42.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -ui -client 0.0.0.0 -bind=$ipaddr -retry-join=$masteripaddr

			# Start registrator
			echo 
			echo docker run --name=registrator -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator consul://localhost:8500

			# Start python webservice
			echo docker run --name=pythonweb -it -p 8000:80 python/server

			clearenv
		else			
			echo machine app0$i doesnot exists			
		fi
	done
}

#
# Start consul server, only the first time
#
function startserver {
	echo "startserver -c04"
	maxexpect=$(($numcon -1))
	echo maxexpect: $maxexpect
	rootagentaddr=""

	for i in $(seq 1 $numcon)
	do
		conexist=`docker-machine ls | grep "^con0$i" | wc -l`		

		if [ "1" = "$conexist" ]
	    then
	    	echo machine con0$i exists, == starting ==
			eval "$(docker-machine env con0$i)"
	        ipaddr=`docker-machine ip con0$i`
#			echo con0$i addr: $ipaddr
			if [ -z "$rootagentaddr" ]
			then
				rootagentaddr=$ipaddr
			fi

			docker run -d --name=con0$i --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -ui -server -advertise=$ipaddr -bind=$ipaddr -ui -retry-join=$rootagentaddr -bootstrap-expect=$maxexpect -log-level=debug

# docker run -d --name=con01 --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' --expose 8500 consul agent -ui -server -bind=192.168.99.100 -ui -retry-join=192.168.99.100 -bootstrap-expect=1 -log-level=debug
# docker run -d --name=con0$i -h con01 -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 172.17.42.1:53:8600/udp -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -ui -server -advertise $ipaddr -bind=$ipaddr -retry-join=$masteripaddr -bootstrap-expect=$maxexpect -log-level=debug
			

			clearenv
		else			
			echo machine con0$i doesnot exists			
		fi
	done
}

#
# Start consul existing docker app
#
function restartapp {
	echo "restartapp -ra"

	for i in $(seq 1 $numapp)
	do
		appexist=`docker-machine ls | grep "^app0$i" | wc -l`		

		if [ "1" = "$appexist" ]
	    then
	    	echo machine app0$i exists, == restarting ==
			eval "$(docker-machine env app0$i)"
	        ipaddr=`docker-machine ip app0$i`
#						
			docker start app0$i

			clearenv
		else			
			echo machine app0$i doesnot exists			
		fi
	done
}

#
# Start consul existing docker app
#
function restartserver {
	echo "restartserver -rs"

	maxexpect=$(($numcon -1))
	echo maxexpect: $maxexpect

	for i in $(seq 1 $numcon)
	do
		conexist=`docker-machine ls | grep "^con0$i" | wc -l`		

		if [ "1" = "$conexist" ]
	    then
	    	echo machine con0$i exists, == restarting ==
			eval "$(docker-machine env con0$i)"
	        ipaddr=`docker-machine ip con0$i`
#						
			docker start con0$i

			clearenv
		else			
			echo machine con0$i doesnot exists			
		fi
	done
}

#
# Stop consul server
#
function stopappserver {
	echo "stopappserver -ax"
	
	for i in $(seq $numapp -1 1)
	do
		appexist=`docker-machine ls | grep "^app0$i" | wc -l`		

		if [ "1" = "$appexist" ]
	    then
	    	echo machine app0$i exists, == stopping ==
			eval "$(docker-machine env app0$i)"

			docker stop app0$i

			clearenv
		else			
			echo machine app0$i doesnot exists			
		fi
	done
}

#
# Stop consul server
#
function stopserver {
	echo "stopserver -sx"
	
	for i in $(seq $numcon -1 1)
	do
		conexist=`docker-machine ls | grep "^con0$i" | wc -l`		

		if [ "1" = "$conexist" ]
	    then
	    	echo machine con0$i exists, == stopping ==
			eval "$(docker-machine env con0$i)"

			docker stop con0$i

			clearenv
		else			
			echo machine con0$i doesnot exists			
		fi
	done
}

function syntax () {
	echo "$1 [-a01] [-c01] [-a02] [-c02] [-a03] [-c03] [-a04] [-c04] [--help] "
	echo " Create (only once)"
	echo "	-a01 create app server"
	echo "	-c01 create consul servers"
	echo " Start machines, after each stop"
	echo "	-a02 start app machine"
	echo "	-c02 start server machine"
	echo " Install software only once)"
	echo "	-a03 install app server software"
	echo "	-c03 install consul servers software"
	echo " Start docker services on machines for first time"
	echo "	-a04 define docker service on app machine"
	echo "	-c04 start docker consul servers"
	echo " Stop docker services"
	echo "	-ax stop docker app servers"
	echo "	-sx stop docker consul servers"
	echo " Restart docker images"
	echo "	-rs restart existing docker consul servers"
	echo "	-ra restart existing docker app server"
	
}

#echo number arguments: $#
app=$0
while [[ $# -ge 1 ]]
do
	key="$1"

	case $key in
		-a01)
			createappserver
		;;

		-c01)
			createserver
		;;

		-a02)
			startappmachine
		;;

		-c02)
			startservermachine
		;;

		-a03)
			installapp
		;;
		
		-c03)
			installserver
		;;
	   
	   	-a04)
			startappservice
		;;

   		-c04)
			startserver
		;;

		-ax)
			stopappserver
		;;

		-sx)
			stopserver
		;;

		-rs)
			restartserver
		;;

		-ra)
			restartapp
		;;

	    --help)
			syntax $app			
			exit
		;;

	    *)
	            # unknown option
	    	echo unknown option $key, nothing executed
	    	syntax $app
	    ;;
	esac
	shift # past argument or value
done