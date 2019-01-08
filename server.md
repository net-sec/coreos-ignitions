G6 380er
ProLiant DL380 Gen6, 2X Intel E5540 2.53 GHz, 2x 460 Watt, 4x LAN, 6x 10 Gb
ProLiant DL380 Gen6, 2X Intel E5540 2.53 GHz, 2x 460 Watt, 4x 1 GB, 


G7 380er
ProLiant DL380 Gen7, 32 GB, 2X Intel E5630 2.53 GHz, 3x 146GB, 2x 460 Watt, 4x LAN,
ProLiant DL380 Gen7, 12 GB, 1x Intel E5640 2.66 GHz, 3x 72GB, 2x 460 Watt, 6x 1 GB, 
ProLiant DL380 Gen7, 12 GB, 2x Intel E5640 2.66 GHz, 3x 72GB, 2x 460 Watt, 6x 1 GB, 



2 DNS - schwachbrüstig
3 Fileserver - Cisco von Mathias

2 Rancher Master - schwachbrüstig
4 Rancher Agents - DL580er


G7 Rancher Master-1 und DNS-1
ProLiant DL380 Gen7, 96 GB, 2x Intel X5677 3.47, 2x 750 Watt, 4x 1 GB, 
G7 Rancher Master-2 und DNS-2
ProLiant DL380 Gen7, 68 GB, 2x Intel L5630 2.13, 2x 750 Watt, 4x 1 GB, 


G7 580er - Kubernetes Nodes
ProLiant DL580 Gen7, 112 GB, 4x Intel Xenon  X7559 2.0 GHZ, 4x 1200 Watt, 8x 1 GB, 4x 10 Gb
ProLiant DL580 Gen7, 256 GB, 4x Intel Xenon  X7559 2.0 GHZ, 4x 1200 Watt, 8x 1 GB, 4x 10 Gb
ProLiant DL580 Gen7, 128 GB, 4x Intel Xenon  X7559 2.0 GHZ, 4x 1200 Watt, 8x 1 GB, 4x 10 Gb
ProLiant DL580 Gen7, 128 GB, 4x Intel Xenon  X7559 2.0 GHZ, 4x 1200 Watt, 8x 1 GB, 4x 10 Gb





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