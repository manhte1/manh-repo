#SLS suricata install
#Updated: May 05th 2016 by manh.nguyen

###---Set info in HERE---#####
{% set apvera_sensor = 'T1600'  %}
{% set suricata_mode = 'af-packet' %}  #suricara_mode="af-packet" or "nfqueue"
                                     # This will be set in /etc/default/suricata as well
{% set suricata_deb = 'suricata_3.0.1_amd64_v2.deb' %}
###---Set info in HERE---#####


#####---DO NOT EDIT FROM HERE---#####
{% if apvera_sensor == 'T1600' -%}
  {% set mgmt = 'eth0' %}
  {% set eth1 = 'p1p1' %}
  {% set eth2 = 'p2p1' %}
 {% elif apvera_sensor == 'T800' -%}
  {% set mgmt = 'em1' %}
  {% set eth1 = 'em3' %}
  {% set eth2 = 'em4' %}
 {% elif apvera_sensor == 'T1600-desktop' -%}    #T1600 is installed Ubuntu 14.04 Desktop
  {% set mgmt = 'eth0' %}
  {% set eth1 = 'eth1' %}
  {% set eth2 = 'eth2' %}
{% endif %}

include:
     - suricata.dependencies

force_dependency_install:
   cmd.run:
     - name: apt-get -f -y install
     - user: root
     - require_in: install_suricata

install_suricata:
   cmd.run:
     - name: dpkg -i /tmp/{{ suricata_deb }}
#     - unless: dpkg -s suricata              #Check if suricata was installed
     - require:
       - file: /tmp/{{ suricata_deb }}
   service.running:
     - name: suricata
     - enable: True
     - restart: True
     - require:
        - file: /etc/suricata/suricata.yaml
        - file: /etc/suricata/classification.config
        - file: /etc/suricata/reference.config
        - file: /etc/suricata/threshold.config
        - file: /etc/default/suricata
        - file: /etc/init.d/suricata

/tmp/{{ suricata_deb }}:
   file.managed:
      - name: /tmp/{{ suricata_deb }}
      - source: salt://suricata/files/{{ suricata_deb }}
      - unless: /tmp/{{ suricata_deb }} # Check if existing
/etc/suricata/suricata.yaml:
   file.managed:
      - source: salt://suricata/files/suricata.yaml.jinja
      - reload: True
      - makedirs: True
      - template: jinja

/etc/default/suricata:
   file.managed:
      - source: salt://suricata/files/suricata.default.jinja
      - template: jinja
      - create: True

/etc/init.d/suricata:
   file.managed:
      - source: salt://suricata/files/suricata_etc_init.d
      - mode: 751
      - makedirs: True

/etc/suricata/classification.config:
   file.managed:
      - source: salt://suricata/files/classification.config
      - makedirs: True

/etc/suricata/reference.config:
   file.managed:
      - source: salt://suricata/files/reference.config
      - makedirs: True

/etc/suricata/threshold.config:
   file.managed:
      - source: salt://suricata/files/threshold.config
      - makedirs: True

/etc/suricata/rules:
   file.recurse:
      - source: salt://suricata/files/rules
      - makedirs: True

/var/log/suricata:
  file.directory:
     - makedirs: True
