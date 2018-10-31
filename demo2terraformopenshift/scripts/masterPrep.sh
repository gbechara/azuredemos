#!/bin/bash
echo $(date) " - Starting Script"

STORAGEACCOUNT=$1
SUDOUSER=$2
LOCATION=$3

# Install EPEL repository
echo $(date) " - Installing EPEL"

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

# Update system to latest packages and install dependencies
echo $(date) " - Update system to latest packages and install dependencies"

yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct httpd-tools
yum -y install cloud-utils-growpart.noarch
yum -y update --exclude=WALinuxAgent

# Only install Ansible and pyOpenSSL on Master-0 Node
# python-passlib needed for metrics

if hostname -f|grep -- "-0" >/dev/null
then
   echo $(date) " - Installing Ansible, pyOpenSSL and python-passlib"
   yum -y --enablerepo=epel install ansible pyOpenSSL python-passlib
#   echo $(date) " - Installing Ansible, pyOpenSSL, python-cryptography and python-lxml"
#   yum -y --enablerepo=epel install ansible pyOpenSSL python-cryptography python-lxml
fi

# Install java to support metrics
echo $(date) " - Installing Java"

yum -y install java-1.8.0-openjdk-headless

# Grow Root File System
echo $(date) " - Grow Root FS"

rootdev=`findmnt --target / -o SOURCE -n`
rootdrivename=`lsblk -no pkname $rootdev`
rootdrive="/dev/"$rootdrivename
name=`lsblk  $rootdev -o NAME | tail -1`
part_number=${name#*${rootdrivename}}

growpart $rootdrive $part_number -u on
xfs_growfs $rootdev

# Install Docker docker-1.13.1
echo $(date) " - Installing Docker docker-1.13.1"

yum -y install docker-1.13.1
# Create thin pool logical volume for Docker
echo $(date) " - Creating thin pool logical volume for Docker and staring service"

DOCKERVG=$( parted -m /dev/sda print all 2>/dev/null | grep unknown | grep /dev/sd | cut -d':' -f1 )

echo "DEVS=${DOCKERVG}" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
docker-storage-setup
if [ $? -eq 0 ]
then
   echo "Docker thin pool logical volume created successfully"
else
   echo "Error creating logical volume for Docker"
   exit 5
fi

echo $(date) " - Changing docker config file" 
sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker
#sed -i -e "s#^OPTIONS=' --selinux-enabled       --signature-verification=False'#OPTIONS='--selinux-enabled=false --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker

# Enable and start Docker services

echo $(date) " - Enabling and starting docker" 
systemctl enable docker
systemctl start docker

# Create Storage Class yml files on MASTER-0

if hostname -f|grep -- "-0" >/dev/null
then
cat <<EOF > /home/${SUDOUSER}/scunmanaged.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: generic
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/azure-disk
parameters:
  location: ${LOCATION}
  storageAccount: ${STORAGEACCOUNT}
EOF

cat <<EOF > /home/${SUDOUSER}/scmanaged.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: generic
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/azure-disk
parameters:
  kind: managed
  location: ${LOCATION}
  storageaccounttype: Premium_LRS
EOF

fi

echo $(date) " - Script Complete"