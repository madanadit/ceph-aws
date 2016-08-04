#!/bin/bash

RGW0=`cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | grep mon0 -m 1`
MON_HOST=`cut -d "=" -f 2 <<< $RGW0 | cut -d " " -f 1 | xargs`

vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE service-create --name swift --type object-store"

SERVICE_ID=`vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE service-list | awk '/ object-store / {print $2}'"`
SERVICE_ID=`echo $SERVICE_ID | cut -d "|" -f 2 | xargs`
echo "Service " $SERVICE_ID

vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE endpoint-create --region RegionOne --service-id ${SERVICE_ID} --publicurl http://${MON_HOST}:8080/swift/v1 --internalurl http://${MON_HOST}:8080/swift/v1 --adminurl http://${MON_HOST}:8080/swift/v1"

vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE tenant-create --name ceph"
vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE user-create --name ceph --pass ceph --tenant-id ceph --enabled true"
vagrant ssh mon0 -c "keystone --os-endpoint http://localhost:35357/v2.0 --os-token mKECk0hrJTczWrCd0fCE user-role-add --user ceph --tenant ceph --role admin"

KEYSTONE_AUTH=http://${MON_HOST}:35357/v2.0
KEYSTONE_USER=ceph:ceph

echo "auth_url      " $KEYSTONE_AUTH
echo "auth_host     " $MON_HOST
echo "user:subuser  " $KEYSTONE_USER
echo "password       ceph"
