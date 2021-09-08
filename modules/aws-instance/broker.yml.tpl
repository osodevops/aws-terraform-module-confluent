#!/usr/bin/env bash
systemctl stop firewalld
systemctl disable firewalld
echo "Sleeping for 1 min to allow volume to become attached....."
sleep 1m
export VOLUME_STAT="`file -s /dev/sdh`"
if [[ $VOLUME_STAT == *"ext4"* ]]; then
echo "Volume already formatted (data exists)"
mkdir -p /var/lib/kafka/data
mount /dev/sdh /var/lib/kafka/data
else
echo "Blank volume, formatting...."
mkfs -F -t ext4 /dev/sdh
mkdir -p /var/lib/kafka/data
mount /dev/sdh /var/lib/kafka/data
fi
echo /dev/sdh /var/lib/kafka/data ext4 defaults,nofail 0 2 >> /etc/fstab
rm -R /var/lib/kafka/data/lost+found
sudo yum install -y amazon-efs-utils
mkdir /efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${file_system_id}.efs.eu-west-2.amazonaws.com:/ efs