ceph-ansible-aws
================

AWS deployment for Ceph using ceph-ansible playbook.

Prerequisites:
* git
* aws-vagrant
* ansible (tested v2.1.0.0)

Assumptions / limitations:
* a security group named 'test-open' has been created on aws
* launch aws instance has interface 'eth0'
* pool_default_size is always 1

## How to use
* Clone ceph-ansible and configure
```
./setup.sh
```

* Modify configuration
```
vi ceph-ansible/vagrant_variables.yml
```

* Use vagrant to launch a Ceph cluster
```
cd ceph-ansible
vagrant up
``` 

* Generate Swift client parameters  
```
./get-swift-config.sh
```

## Manual Instructions (for debugging purposes)

* Clone ceph-ansible
```
$ git clone --branch v1.0.5 https://github.com/ceph/ceph-ansible.git
```

* Modify configuration in 'vagrant_variables.yml'

* Modify ceph-ansible/Vagrantfile
```
aws.security_groups = [ 'test-open' ]
```

* Modify ceph-ansible/ansible.cfg: ssh control_path to a shorter length

* Modify ceph-ansible/group_vars/all
```
monitor_interface: eth0
journal_size: 1024 # OSD journal size in MB
```

* Modify ceph-ansible/group_vars/mons

* Modify ceph-ansible/group_vars/osds
```
devices:
  - /dev/xvdc
``` 

* Modify ceph-ansible/group_vars/rgws

* Modify ceph-ansible/site.yml

* Modify ceph-ansible/vagrant_variables.yml

* Check health of Ceph cluster on monitor node
```
sudo ceph -s
sudo ceph health
sudo ceph osd pool ls
sudo rados mkpool data
sudo rados df 
sudo rados put -p data test-file.out test-file.out
rados ls -p data
```

* Create Swift user and key on rados gateway node
```
$ sudo radosgw-admin user create --uid=ceph-swift --display-name="Ceph Swift"
$ sudo radosgw-admin subuser create --uid=ceph-swift --subuser=ceph-swift:ceph-swift --access=full
$ sudo radosgw-admin key create --subuser=ceph-swift:ceph-swift --key-type=swift --gen-secret
```
