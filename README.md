# Ansible tasks

##### Docker Usage:

*For installing Docker in local system:*

- Set hosts to localhost in docker.yml

```yaml
- hosts: localhost
  become: yes
  roles:
         - docker_ubuntu
```
- Add system Public IPv4 in inventory

*For installing Docker in any other server:*

- Set hosts to all in docker.yml

```yaml
- hosts: all
  become: yes
  roles:
         - docker_ubuntu
```
- Add server Public IPv4 in inventory file

- Set the private key file path of server for SSH in ansible.cfg
```bash
[defaults]

private_key_file = /etc/ansible/ubuntu.pem
```
- Run the playbook with the following command
```bash
ansible-playbook docker.yml
```

##### Kubernetes Usage:

*For installing Kubernetes in both Master & Slave system:*

- Set path to private key file in ansible.cfg

```bash
[defaults]

private_key_file = /etc/ansible/private_key_file.pem
```

- Set permission of your private key file to `Owner can read`
```bash
chmod 400 /etc/ansible/private_key_file.pem
```

- Add Master & Slave server Public IPv4 in inventory file

```bash
[kube_master]
54.82.75.140

[kube_slave]
52.87.175.205
```

*Run the playbook with the following command:*
```bash
ansible-playbook multiNode.yml
```
- Copy & Paste the token to join the kubernetes cluster when prompted

```yaml
TASK [k8s_master : Print the command to join the slave nodes] ******************
ok: [34.236.156.40] => {
    "join_command.stdout_lines": [
        "kubeadm join 172.31.17.144:6443 --token zooq9g.5wzl47wd0yirjesr --discovery-token-ca-cert-hash sha256:1edef2be737c1747fdf1678ad48584ced3ab233de9b972db991288ff51d16ff1 "
    ]
}
Enter the token to join the kubernetes cluster: 
```
