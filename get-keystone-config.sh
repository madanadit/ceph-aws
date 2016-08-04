#!/bin/bash

vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE tenant-create --name=ceph"
vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE user-create --name=ceph --pass ceph tenant-id=ceph --enabled true"

RGW0=`cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | grep mon0 -m 1`
MON_HOST=`cut -d "=" -f 2 <<< $RGW0 | cut -d " " -f 1`

KEYSTONE_AUTH=http://${MON_HOST}:35357/v2.0
KEYSTONE_USER=ceph:ceph

echo "auth_url      " $KEYSTONE_AUTH
echo "auth_host     " $MON_HOST
echo "user:subuser  " $KEYSTONE_USER
echo "password       ceph"
