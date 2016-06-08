mitm_dependencies:
  cmd.run:
    - name: apt-get -y install python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev

mitm_install:
  cmd.run:
   - name: pip install mitmproxy
   - require:
      - cmd: mitm_dependencies
#--------http2https---------------
/etc/mitm/http2https.py:
  file.managed:
    - name: /etc/mitm/http2https.py
    - contents: |
         #http2https.py
         def request(context, flow):
             if flow.request.port == 80:
                flow.request.scheme = "https"
                flow.request.port = 443
         def responseheaders(context, flow):
                flow.response.stream = False
    - makedirs: True
    - show_diff: True
#--------https2http---------------
/etc/mitm/https2http.py:
  file.managed:
    - name: /etc/mitm/https2http.py
    - contents: |
        #https2http.py
        def request(context, flow):
            if flow.request.scheme == "https":
               flow.request.scheme = "http"
               flow.request.port = 80
        def responseheaders(context, flow):
               flow.response.stream = False
    - makedirs: True
    - show_diff: True
#--------Iptables to run NFQ and MITM----
/etc/mitm/iptables_nfq.sh:
  file.managed:
    - name: /etc/mitm/iptables_nfq.sh
    - mode: 777
    - source: salt://mitm/iptables_nfq.sh
/etc/crontab:
  file.managed:
    - name: /etc/crontab
    - marker_start: "#Managed by Apvera - Start#"
    - marker_end: "#Managed by Apvera - End#"
    - contents: |
        @reboot /etc/mitm/iptables_nfq.sh
        @reboot modprobe br_netfilter
        suricata -q 0 -D --runmode autofp
    - show_changes: True

