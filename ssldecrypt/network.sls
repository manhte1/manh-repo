{% from "ssldecrypt/init.sls" import mgmt_ipaddr, mgmt_gw, mgmt_netmask, mgmt_dns with context %}
/etc/network/interfaces.d.bak:
  cmd.run:
    - name: mv /etc/network/interfaces.d /etc/network/interfaces.d.bak
#Start Edit network configuration:
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

/etc/network/interfaces.d/{{ eth3 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ eth3 }}.cfg
    - contents: |
       auto {{ eth3 }}
       iface {{ eth3 }} inet manual
       up ifconfig {{ eth3 }} 0.0.0.0 up
       down ifconfig {{ eth3 }} down
       post-up for i in rx tx sg tso ufo gso gro lro; do ethtool -K {{ eth3 }} $i off; done
    - makedirs: True
    - show_diff: True

/etc/network/interfaces.d/{{ eth4 }}.cfg:
  file.managed:
    - name: /etc/network/interfaces.d/{{ eth4 }}.cfg
    - contents: |
       auto {{ eth4 }}
       iface {{ eth4 }} inet manual
       up ifconfig {{ eth4 }} 0.0.0.0 up
       down ifconfig {{ eth4 }} down
       post-up for i in rx tx sg tso ufo gso gro lro; do ethtool -K {{ eth4 }} $i off; done
    - makedirs: True
    - show_diff: True
