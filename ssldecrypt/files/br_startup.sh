{% from "ssldecrypt/init.sls" import br0_ip, br0_netmask with context %}
brctl addbr br0
brctl addif br0 p1p1
brctl addif br0 p2p1
ifconfig br0 up
ifconfig br0 {{ br0_ip }} netmask {{ br0_netmask }}
modprobe br_netfilter
sysctl -p
