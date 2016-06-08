#NFQ_iptables

#modprobe br_netfilter
#sysctl -p
#route add default gw 192.168.1.1 br0

iptables=/sbin/iptables
br0_ip='10.51.177.192'
mitm1_uid='1001'
mitm2_uid='1002'
default_gateway='10.51.177.1'
mgmt_ip='192.168.100.20'

# config iptables and routing on ips
iptables -t nat -F
iptables -t mangle -F
iptables -F

#-- alL FORWARD traffic will be sent to NFQ
iptables -I FORWARD -j NFQUEUE

#--Pre NAT 443 port to 8443 with source is not br0 ($br0_ip)
iptables -t nat -A PREROUTING -i br0 -p tcp ! -s $br0_ip/32 ! -d $br0_ip/32 --dport 443 -j DNAT --to $br0_ip:8443
iptables -t nat -A OUTPUT -p tcp -s $mgmt_ip/32 -m owner --uid-owner $mitm1_uid -j DNAT --to-destination $br0_ip:8543
iptables -t nat -A POSTROUTING -s $mgmt_ip ! -d $br0_ip -m mark --mark 44 -j SNAT --to-source $br0_ip
iptables -t mangle -A INPUT -s $br0_ip -p tcp --dport 8543 -j NFQUEUE
iptables -t mangle -A INPUT -d $br0_ip -p tcp --sport 8543 -j NFQUEUE

# routing for proxy going rightway ( not by management interface)
iptables -t mangle -A OUTPUT -m owner --uid-owner $mitm2_uid -j MARK --set-mark 44
ip rule add fwmark 44 table 42
ip route add default via $default_gateway dev br0 table 42

#start mitmproxy
#su mitm1 -c "mitmdump -T --host -p 8443 -s /etc/suricata/https2http.py --no-upstream-cert --ignore 0.0.0.0/0 --ssl-version-server 'TLSv1' --ciphers-server= 'DHE-RSA-AES256-SHA' "
#su mitm2 -c "mitmdump -T --host -p 8543 -s /etc/suricata/http2https.py --no-upstream-cert --ignore 0.0.0.0/0 --ssl-version-client 'TLSv1'"

