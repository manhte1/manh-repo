#Guide to set up SSLdecrypt for Salt
#Topology

#SLS run:
- Install suricata by suricata SLS first
- Set variable in slsdecrypt/init.sls:
   + IP (management and Br0)

- Run ssldecrypt sls. bellow info will be configured:
  + mitm installing
  + network: eth0 as management
             p1p1, p2p1 as bridge in br0
             p3p1, eth4 as af-packet
  + crontab: start bridge intereface and IPTABLES after reboot
  + mitm listen port 8443
