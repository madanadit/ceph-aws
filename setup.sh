#!/bin/bash

git clone https://github.com/ceph/ceph-ansible.git
pushd .
cd ceph-ansible
git checkout 46720ebf4a4c9997fa791c0a8b481b10efa775ca
popd

cp conf/Vagrantfile ceph-ansible/Vagrantfile
cp conf/ansible.cfg ceph-ansible/ansible.cfg
cp conf/site.yml ceph-ansible/site.yml
cp conf/vagrant_variables.yml ceph-ansible/vagrant_variables.yml
cp conf/group_vars/* ceph-ansible/group_vars/
