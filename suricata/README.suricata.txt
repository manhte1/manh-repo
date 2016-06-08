-------------------------------------------
HOW TO APPLY SURICATA SLS
-------------------------------------------

1. Copy suricata SLS folder to /srv/salt/
2. Add suricata to top.sls

#---content of top.sls-----
base:
  'minion1'
    - suricata
#---content of top.sls-----

3. Run install suricata for minion by command:
  salt 'minion1' state.highstate

4. Note: If there is error in "dependencies" state
  4.1. Rum command "apt-get install -f":
       salt 'minion1' cmd.run "apt-get install -f"
	   
  4.2. Run again:
  salt 'minion1' state.highstate
  
=> Suricata was installed for minion1

5. Update DEB version of suricata:
   5.1 Copy new DEB file to /srv/salt/suricata/files
   5.2 Edit DEB file name in init.sls
   5.4 Run state.highstate
