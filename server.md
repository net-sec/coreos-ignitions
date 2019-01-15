#Installation so far - i salted it btw: https://github.com/claudio-walser/salt

nano /etc/apt/sources.list
	deb http://ftp.ch.debian.org/debian/ stretch non-free
	deb-src http://ftp.ch.debian.org/debian/ stretch non-free

apt-get -y install sudo net-tools iputils-ping bash-completion firmware-netxen firmware-qlogic firmware-bnx2x

fdisk /dev/sdb
mkfs.ext4 /dev/sdb1

mkdir -p /var/lib/docker
nano /etc/fstab 
	/dev/sdb1       /var/lib/docker         ext4    rw,noatime,data=writeback,nobarrier     0 1
nano /etc/sudoers
	%sudo ALL=NOPASSWD: ALL
nano /etc/shadow
	root:!:...
	...
	claudio:!:...
adduser claudio sudo

sudo -u claudio mkdir /home/claudio/.ssh
sudo -u claudio nano /home/claudio/.ssh/authorized_keys
	ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyvOm1lNZQDREfzZyTrR3rFXlqOkcg/gm0qj0Bohi/KSBNrY3Lb2b/7XtAGc6kp4DOYwvyH0I6GxAkQP6heA72OYd3T0sSK/RcMFQHW0DAVTV6CiRhCUV4fKwS57hnZ02sEP3on7gaCD5Mf8gm+zwSoLa+jgZ2MMQrwIz+BcE2rXrMXuPF4QAn9SHSpKA+ja8V/o89Dt4J58awWe3MsccpEnnvkyGoNb82h+Xl96OrCO1Kw5fiuk0LbOs5iVEnxu6rDcU0KFphE4Ggep/BtVPjSwYQDn3fAZ0z3TAUOisi7o+2tY8dq8+AuuvgsUnwpaiUQHpDlxurK5ZQ0/YFzxlVqq1Dm2rk1tuum7xhjimc5HbC5Jq+f7cB9C5MfC7I+uVfjS7PILqY+JEvayTr7C8tYEqD0hF/mmnePLMvTdnL6E5dpkkLKw9DjL3PGpn1KSlspGfY3GRkjzdiMUtrDDym42EflqJn3zAGlm8ZlA2INmOmUgeNr1JJTK2AjycqYIB/GVgG/J6kqf9HaFijGwuSxlyGq3OajKNgtL/WYhpK1O88FXV3rYi03CeG1kdQ3okigibuY+OnKsviUGlOwD+9BHnMnM1exfIYkpflAWI9GxGgFpM7RFuA3Mbag3KeJ0pM7zz+KBPeuSgubVpgpvRe3sIQQ6EWt77kgYk6Ma7C7w== claudio@net-sec.local
sudo -u claudio nano /home/claudio/.bashrc 
	# my stuff
	alias god='sudo su -'

	# default shizzle

adduser local-admin

nano /etc/ssh/sshd_config
	AllowUsers claudio