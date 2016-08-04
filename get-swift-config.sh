#!/bin/bash

#pushd .
#cd ceph-ansible
vagrant ssh mon0 -c "sudo radosgw-admin user create --uid=ceph --display-name='Ceph Swift'"
vagrant ssh mon0 -c "sudo radosgw-admin subuser create --uid=ceph --subuser=ceph:ceph --access=full"
KEY=`vagrant ssh mon0 -c "sudo radosgw-admin key create --subuser=ceph:ceph --key-type=swift --gen-secret" | grep "ceph:ceph" -A 1 | grep "secret_key"`
KEY=${KEY##*:}

RGW0=`cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | grep mon0 -m 1`
MON_HOST=`cut -d "=" -f 2 <<< $RGW0 | cut -d " " -f 1`
#popd

SWIFT_AUTH=http://${MON_HOST}:8080/auth
SWIFT_USER=ceph:ceph
SWIFT_KEY=${KEY//\"}

echo "auth_url      " $SWIFT_AUTH
echo "auth_host     " $MON_HOST
echo "user:subuser  " $SWIFT_USER
echo "key           " $SWIFT_KEY

export CEPH_SWIFT_KEY=$SWIFT_KEY
export CEPH_AUTH_HOST=$MON_HOST

echo $CEPH_SWIFT_KEY > .swift-credentials
echo $CEPH_AUTH_HOST >> .swift-credentials
