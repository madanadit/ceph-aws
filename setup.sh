#!/bin/bash

git clone https://github.com/ceph/ceph-ansible.git
pushd .
cd ceph-ansible
git checkout 46720ebf4a4c9997fa791c0a8b481b10efa775ca
popd

git clone https://github.com/openstack-ansible/ansible-role-keystone.git

cp conf/Vagrantfile Vagrantfile

mkdir -p plugins/actions
cp ceph-ansible/plugins/actions/* plugins/actions/
cp conf/ansible.cfg ansible.cfg
cp conf/ansible.cfg ceph-ansible/ansible.cfg
cp conf/ansible.cfg ansible-role-keystone/ansible.cfg

cp conf/vagrant_variables.yml vagrant_variables.yml

cp conf/site.yml ceph-ansible/site.yml
cp conf/group_vars/* ceph-ansible/group_vars/

#cp conf/main.yml ansible-role-keystone/defaults/main.yml
