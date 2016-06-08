#ifdown eth0 && sudo ifup -v eth0
#This SLS for T1600 sensor. Pls modify IP management of sensor in ./files/eth0.cfg
{% set mgmt = 'eth0' %}
{% set mgmt_ipaddr = '10.51.177.195' %}
{% set mgmt_netmask = '255.255.255.0' %}
{% set mgmt_gw = '192.168.100.1' %}
{% set mgmt_dns = '8.8.8.8' %}

{% set br0 = 'br0' %}
{% set br0_ipaddr = '10.51.177.192' %}
{% set br0_netmask = '255.255.255.0' %}
{% set br0_gw = '10.51.177.1' %}
{% set br0_dns = '8.8.8.8' %}

{% set apvera_sensor = 'T1600'  %}
{% if apvera_sensor == 'T1600' -%}
  {% set eth1 = 'p1p1' %}
  {% set eth2 = 'p2p1' %}
 {% elif apvera_sensor == 'T800' -%}
  {% set eth1 = 'em1' %}
  {% set eth2 = 'em2' %}

{% endif %}

############# T1600 - NFQUEUE ######################
#-----Install and configure bridge------------------
bridge-utils:
  pkg.installed:
    - name: bridge-utils
br_netfilter:
  cmd.run:
    - name: modprobe br_netfilter
    - user: root
    - require: 
       - pkg: bridge-utils
modprobe:
  cmd.run:
    - name: sysctl -p 
    - require:
       - cmd: br_netfilter
       - file: /proc/sys/net/bridge/bridge-nf-call-iptables
       - file: /proc/sys/net/bridge/bridge-nf-call-ip6tables
/proc/sys/net/bridge/bridge-nf-call-iptables:
  file.managed:
    - contents: 1
    - makedirs: True
/proc/sys/net/bridge/bridge-nf-call-ip6tables:
  file.managed:
    - contents: 1
    - makedirs: True
#----------------------------------------------------
#-------Configure interface--------------------------
/etc/network/interfaces.d/{{ mgmt }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ mgmt }}.cfg
#    - makedirs: True
    - contents: |
        auto {{ mgmt }}
        iface {{ mgmt }} inet static
          address {{ mgmt_ipaddr }}
          netmask {{ mgmt_netmask }}
          #network 192.168.1.0
          #broadcast 192.168.254.255
          #gateway {{ mgmt_gw }}
          # dns-* options are implemented by the resolvconf package, if installed
          dns-nameservers {{ mgmt_dns }}
          dns-search apvera.com
    - makedirs: True
    - show_diff: True


/etc/network/interfaces.d/{{ eth1 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ eth1 }}.cfg
#    - makedirs: True
    - contents: |
        auto {{ eth1 }}
        iface {{ eth1 }} inet manual
        up ifconfig {{ eth1 }} 0.0.0.0 up
        down ifconfig {{ eth1 }} down
    - makedirs: True
    - show_diff: True


/etc/network/interfaces.d/{{ eth2 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ eth2 }}.cfg
#    - makedirs: True
    - contents: |
        auto {{ eth2 }}
        iface {{ eth2 }} inet manual
        up ifconfig {{ eth2 }} 0.0.0.0 up
        down ifconfig {{ eth2 }} down
    - makedirs: True
    - show_diff: True

/etc/network/interfaces.d/{{ br0 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ br0 }}.cfg
    - contents: |
        auto {{ br0 }}
        iface {{ br0 }} inet static
        bridge_ports {{ eth1 }} {{eth2}}
        address {{ br0_ipaddr }}
        netmask {{ br0_netmask }}
        gateway {{ br0_gw }}
        dns-nameservers {{ br0_dns}}
    - makedirs: True
    - show_diff: True
    - require:
      - pkg: bridge-utils
#-------Configure interface--------------------------
#Edit sysctl.conf to enable bridge-util
/etc/sysctl.conf:
  file.blockreplace:
    - name: /etc/sysctl.conf
    - marker_start: "#--BY-APVERA--Start--#"
    - marker_end: "#--BY-APVERA--End--#"
    - content: |
       net.ipv4.ip_forward=1
       net.bridge.bridge-nf-call-iptables=1
       net.bridge.bridge-nf-call-ip6tables=1
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True
