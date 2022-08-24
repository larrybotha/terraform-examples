[docean_droplets]
%{ for ip in ips ~}
${ip}
%{ endfor ~}

[docean_droplets:vars]
ansible_user=${ssh_user}
