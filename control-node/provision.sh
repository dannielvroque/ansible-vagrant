#/bin/sh
echo "install epel-release"
sudo yum install epel-release -y
echo "install ansible"
sudo yum install ansible -y
cat <<EOT >> /etc/hosts
192.168.1.10 control-node
192.168.1.11 app01
192.168.1.12 db01
EOT
