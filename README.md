ceph-ansible-aws
================

AWS deployment for Ceph with Keystone integration using ceph-ansible and ansible-role-keystone playbooks.

Prerequisites:
* git
* vagrant (tested with v1.8.4)
* ansible (tested with v1.9.4)

Assumptions / limitations:
* a security group named 'test-open' exists on AWS
* launched AWS instance has interface 'eth0'

## How to use
* Clone required repositories and configure
```
./setup.sh
```

* Modify configuration to specify AWS credentials
```
vi vagrant_variables.yml
```

* Use vagrant to launch a Ceph cluster with Keystone integration
```
vagrant up mon0 --no-parallel && vagrant up osd0 osd1 osd2 --parallel
``` 

* Generate Swift client parameters (v1.0 only)
```
./get-swift-config.sh
```

* Generate Keystone client parameters (v2.0 only)
```
./get-keystone-config.sh
```

* Remove cloned repositories
```
./cleanup.sh
```

## Manual Instructions (for debugging purposes)

* Clone ceph-ansible
```
$ git clone https://github.com/ceph/ceph-ansible.git
```

* Specify AWS credentials in 'vagrant_variables.yml' (skip if not using vagrant)
```
<YOUR_KEY>
<YOUR_SECRET>
<YOUR_KEYPAIR>
<YOUR_KEYPATH>
```

* Copy Vagrantfile from 'conf' (skip if not using vagrant)
```
cp conf/Vagrantfile .
```

* Modify ceph-ansible/ansible.cfg
```
[ssh_connection]
control_path = %(directory)s/%%h-%%r
```

* Modify ceph-ansible/group_vars/all
```
monitor_interface: eth0
radosgw_keystone: true
radosgw_keystone_url: http://localhost:35357 #Assuming RGW and keystone services are co-located
radosgw_keystone_admin_token: mKECk0hrJTczWrCd0fCE #Keystone token visible in /etc/keystone/keystone.conf
radosgw_keystone_accepted_roles: Member, _member_, admin
radosgw_keystone_token_cache_size: 10000
radosgw_keystone_revocation_internal: 900
radosgw_nss_db_path: /var/lib/ceph/radosgw/ceph-radosgw.{{ ansible_hostname }}/nss
```

* Modify ceph-ansible/group_vars/mons
```
mon_group_name: mons
```

* Modify ceph-ansible/group_vars/osds
```
journal_collocation: true
``` 

* Modify ceph-ansible/group_vars/rgws
```
copy_admin_key: true
```

* Clone ansible-role-keystone
```
$ git clone https://github.com/openstack-ansible/ansible-role-keystone.git
```

* Modify ansible-role-keystone/defaults/main.yml
```
openstack_identity_admin_token: mKECk0hrJTczWrCd0fCE #Hard-code token instead of auto-generate
```

* Modify ansible-role-keystone/ansible.cfg
```
[defaults]
host_key_checking = false
roles_path = roles
gathering = smart
nocows = 1

[ssh_connection]
pipelining = true
```

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

* Create Swift user and key on rados gateway node (only for v1 authentication)
```
$ sudo radosgw-admin user create --uid=ceph-swift --display-name="Ceph Swift"
$ sudo radosgw-admin subuser create --uid=ceph-swift --subuser=ceph-swift:ceph-swift --access=full
$ sudo radosgw-admin key create --subuser=ceph-swift:ceph-swift --key-type=swift --gen-secret
```

* Create Keystone user, tenant, service and endpoint (only for v2 authentication)
```
$ keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE service-create --name swift --type object-store
$ keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE endpoint-create --region RegionOne --service-id ${SERVICE_ID} --publicurl http://${MON_HOST}:8080/swift/v1 --internalurl http://${MON_HOST}:8080/swift/v1 --adminurl http://${MON_HOST}:8080/swift/v1
$ keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE tenant-create --name ceph
$ keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE user-create --name ceph --pass ceph --tenant-id ceph --enabled true
$ keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE user-role-add --user ceph --tenant ceph --role admin
```
