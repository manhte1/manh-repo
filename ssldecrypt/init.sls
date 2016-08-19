#SLS to install mitm proxy
#By Apvera: manh.nguyen
#
#mitm install
#suricata install
#configure suricata with af run p1p1-eth4
#network configure eth0-p1p1-p2p1-p3p1-eth4
#
#####---Set IP management HERE---#####
{% set mgmt_ipaddr = '192.168.1.201' %}
{% set mgmt_netmask = '255.255.255.0' %}
{% set mgmt_gw = '192.168.1.1' %}
{% set mgmt_dns = '8.8.8.8' %}

#####---Set IP br0 for mitmproxy HERE---#####
{% set br0_ipaddr = '192.168.1.202' %}
{% set br0_netmask = '255.255.255.0' %}
{% set br0_gw = '192.168.1.1' %}

#Set model of sensor
{% set apvera_sensor = 'T1600'  %} #'T1600' or 'T800' or T1600-desktop
#####---Set IP management HERE(end)---#####

####---DO NOT EDIT FROM HERE---#####
{% if apvera_sensor == 'T1600' -%}
  {% set mgmt = 'eth0' %}
  {% set eth0 = 'eth0' %}    #Group1: eth0-eth1-eth2 (eth0 as mgmt)
  {% set eth1 = 'p1p1' %}    #Bypass: eth1-eth2
  {% set eth2 = 'p2p1' %}    #
  {% set eth3 = 'p3p1' %}    #Group2: eth3-eth4-eth5
  {% set eth4 = 'eth4' %}    #Bypass: eth4-eth5
  {% set eth5 = 'p5p1' %}    #
 {% elif apvera_sensor == 'T1600-desktop' -%} #T1600 model sensor with Ubuntu desktop installed
  {% set eth1 = 'eth1' %}
  {% set eth2 = 'eth2' %}
  {% set eth3 = 'eth3' %}
  {% set eth4 = 'eth4' %}
  {% set eth5 = 'eth5' %}
{% endif %}
####---DO NOT EDIT FROM HERE---#####
#-Configure network -----------------------
include:
  - network

#-Install mitmproxy -----------------------
mitm_dependencies:
  cmd.run:
#    - name: apt-get -y install python-pip python-dev libffi-dev libssl-dev libxm                                                                              l2-dev libxslt1-dev libjpeg8-dev zlib1g-dev
    - name: apt-get -y install python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev
mitm_install:
  cmd.run:
   - name: pip install mitmproxy
   - require:
      - cmd: mitm_dependencies

#--Configure Suricata---------------
/etc/suricata/suricata.yaml:
  file.managed:
    - name: /etc/suricata/suricata.yaml
    - source: salt://ssldecrypt/files/suricata_3.0.1.yaml.jinja
    - template: jinja
    - makedirs: True
    - show_diff: True

#--------Iptables to run bridge interface and forward 443 to mitmproxy:8443 ----
/etc/ssldecrypt/iptables_mitm.sh:
  file.managed:
    - name: /etc/ssldecrypt/iptables_mitm.sh
    - mode: 777
    - source: salt://ssldecrypt/files/iptables_mitm.sh.jinja
    - template: jinja

#-------Configure br0 as start_up----
/etc/ssldecrypt/br_startup.sh:
  file.managed:
    - name: /etc/ssldecrypt/br_startup.sh
    - mode: 777
    - source: salt://ssldecrypt/files/br_startup.sh.jinja
    - template: jinja
/etc/crontab:
  file.managed:
    - name: /etc/crontab
    - marker_start: "#Apvera-ssldecrypt-start#"
    - marker_end: "#Apvera-ssldecrypt-end#"
    - contents: |
        @reboot sh /etc/ssldecrypt/br_startup.sh
    - show_changes: True

#-------- Run mitm as startup ----
/etc/init/mitm.conf:
  file.managed:
    - name: /etc/init/mitm.conf
    - contents: |
        start on startup
        task
        exec mitmproxy -T -p 8443
    - user: root
    - makedirs: True
    - mode: 644
    - replace: True
    - show_diff: True
