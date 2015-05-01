# create user
echo "sudo useradd -m -d /home/deployer -s /bin/bash deployer"
echo "sudo su -c \"echo '%deployer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/deployer\""

# upload public key
echo "sudo su - deployer -c \"mkdir -p .ssh && echo '`cat ~/.ssh/id_rsa.pub`' >> .ssh/authorized_keys\""