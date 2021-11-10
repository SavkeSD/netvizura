# netvizura

Before running ansible, please set proper enviroment and variables:
ansible_ssh_host: 192.168.1.18  -- set host
ansible_ssh_port: 22  -- if ssh running on non default port
ansible_ssh_user: vagrant -- user with sudo access

Running ansible with commands:
ansible-playbook -i netvizura-inventory netvizura-playbook.yaml --ask-become-pass 
