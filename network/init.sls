#This SLS for Apvera sensor.
#Install bridge-utils
{% set mgmt = 'eth0' %}
{% set mgmt_ipaddr = '10.51.177.192' %}
{% set mgmt_netmask = '255.255.255.0' %}
{% set mgmt_gw = '10.51.177.1' %}
{% set mgmt_dns = '8.8.8.8' %}

{% set apvera_sensor = 'T1600'  %}
{% if apvera_sensor == 'T1600' -%}
  {% set eth0 = 'eth0' %}    #Group1: eth0-eth1-eth2
  {% set eth1 = 'p1p1' %}    #Bypass: eth1-eth2
  {% set eth2 = 'p2p1' %}    #
  {% set eth3 = 'p3p1' %}    #Group2: eth3-eth4-eth5 
  {% set eth4 = 'eth4' %}    #Bypass: eth4-eth5
  {% set eth5 = 'p5p1' %}    #
 {% elif apvera_sensor == 'T800' -%}
  {% set eth1 = 'em1' %}
  {% set eth2 = 'em2' %}
 {% elif apvera_sensor == 'T1600-desktop' -%}
  {% set eth1 = 'eth1' %}
  {% set eth2 = 'eth2' %}
{% endif %}

############# T1600 - AF ######################

/etc/network/interfaces:
  file.managed:
    - name: /etc/network/interfaces
    - contents: |
       auto lo
       iface lo inet loopback
       source /etc/network/interfaces.d/*.cfg
    - makedirs: True
    - show_diff: True

/etc/network/interfaces.d/{{ mgmt }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ mgmt }}.cfg
    - contents: |
        auto {{ mgmt }}
        iface {{ mgmt }} inet static
          address {{ mgmt_ipaddr }}
          netmask {{ mgmt_netmask }}
          gateway {{ mgmt_gw }}
          # dns-* options are implemented by the resolvconf package, if installed
          dns-nameservers {{ mgmt_dns }}
          dns-search apvera.com
    - makedirs: True
    - show_diff: True


/etc/network/interfaces.d/{{ eth1 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ eth1 }}.cfg
    - contents: |
       auto {{ eth1 }}
       iface {{ eth1 }} inet manual
       up ifconfig {{ eth1 }} 0.0.0.0 up
       down ifconfig {{ eth1 }} down
       post-up for i in rx tx sg tso ufo gso gro lro; do ethtool -K {{ eth1 }} $i off; done
    - makedirs: True
    - show_diff: True


/etc/network/interfaces.d/{{ eth2 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ eth2 }}.cfg
    - contents: |
       auto {{ eth2 }}
       iface {{ eth2 }} inet manual
       up ifconfig {{ eth2 }} 0.0.0.0 up
       down ifconfig {{ eth2 }} down
       post-up for i in rx tx sg tso ufo gso gro lro; do ethtool -K {{ eth2 }} $i off; done
    - makedirs: True
    - show_diff: True
