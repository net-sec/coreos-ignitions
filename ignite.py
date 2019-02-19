#!/usr/bin/env python3

import sys
import os
import argparse
import yaml
import json
import urllib.parse
from pprint import pprint


parser = argparse.ArgumentParser(description='Little tool to create coreos ignition files.')
parser.add_argument('environment', metavar='e', type=str, help='the environment you want to create for')
parser.add_argument('hostname', metavar='h', type=str, help='the hostname you want to create for')

args = parser.parse_args()


class NetworkConfig(object):

	config = {}

	def __init__(self, path):
		if not os.path.exists('%s/network.yaml' % (path)):
			print('network.yaml does not exist in %s' % (path))
			sys.exit(1)

		with open('%s/network.yaml' % (path)) as stream:
			try:
				self.config = yaml.safe_load(stream)
			except yaml.YAMLError as e:
				print('network.yaml has errors: %s' % (e))
				sys.exit(1)

	# get network interfaces
	def getInterfaces(self, hostname):
		interfaces = self.config[hostname]

		# remove virtual ips from interfaces
		if 'vip' in interfaces:
			del interfaces['vip']

		return interfaces

	def getDns(self, hostname):
		return self.config['defaults']['dns']


	# get domain by hostname
	def getDomain(self, hostname):
		# todo: check by hostname otherwise take defaults
		return self.config['defaults']['domain']

	# get environemnts file by hostname
	def getEnvironment(self, hostname):
		if hostname not in self.config:
			print('Config for %s not found in network.yaml' % (hostname))
			sys.exit(1)

		envFile = 'HOSTNAME%3D{}%0A'.format(hostname)
		envFile += 'IP_SERV%3D{}%0A'.format(self.config[hostname]['serv']['address'])
		envFile += 'IP_MGMT%3D{}%0A'.format(self.config[hostname]['mgmt']['address'])
		envFile += 'IP_SYNC%3D{}%0A'.format(self.config[hostname]['sync']['address'])

		if 'vip' in self.config[hostname]:
			numVip = 1
			for myVip in self.config[hostname]['vip']:

				envFile += '{}_KEEPALIVED_SRC%3D{}%0A'.format(myVip['network'].upper(), self.config[hostname][myVip['network']]['address'])
				envFile += '{}_KEEPALIVED_ID%3D{}%0A'.format(myVip['network'].upper(), numVip)
				envFile += '{}_KEEPALIVED_VIP%3D{}%0A'.format(myVip['network'].upper(), myVip['address'])
				envFile += '{}_KEEPALIVED_INTERFACE%3D{}%0A'.format(myVip['network'].upper(), self.config[hostname][myVip['network']]['interface'])
				
				numPeer = 0
				for network in self.config:
					if network != 'defaults' and network != hostname:
						if 'vip' in self.config[network]:
							for foreignVip in self.config[network]['vip']:
								if foreignVip['address'] == myVip['address']:
									if self.config[network][foreignVip['network']]['address']:
										envFile += '{}_KEEPALIVED_PEER_{}%3D{}%0A'.format(myVip['network'].upper(), numPeer, self.config[network][foreignVip['network']]['address'])								
										numPeer += 1
				numVip += 1
		return envFile



path = 'config/%s' % (args.environment)
confPath = 'config'
if not os.path.exists('%s/%s.yaml' % (confPath, args.hostname)):
	print('%s.yaml does not exist in %s' % (args.hostname, confPath))
	sys.exit(1)

network = NetworkConfig(path)
with open('%s/%s.yaml' % (confPath, args.hostname)) as stream:
	try:
		node_config = yaml.safe_load(stream)
		
		if 'storage' not in node_config:
			node_config['storage'] = {}
		if 'files' not in node_config['storage']:
			node_config['storage']['files'] = []

		# set hostname
		node_config['storage']['files'].append({
			'filesystem': 'root',
			'path': '/etc/hostname',
			'mode': 420,
			'contents': {
				'source': 'data:,%s.%s' % (args.hostname, network.getDomain(args.hostname))
			}
		})

		node_config['storage']['files'].append({
			'filesystem': 'root',
			'path': '/etc/env',
			'mode': 420,
			'contents': {
				'source': 'data:,%s' % (network.getEnvironment(args.hostname))
			}
		})

		if 'networkd' not in node_config:
			node_config['networkd'] = {}
		if 'units' not in node_config['networkd']:
			node_config['networkd']['units'] = []

		interfaces = network.getInterfaces(args.hostname)
		dnsServers = network.getDns(args.hostname)

		for interfaceName in interfaces:
			interface = interfaces[interfaceName]

			interfaceSystemdContent = '[Match] \n\
Name=%s\n\
\n\
[Network]\n\
Address=%s/24\n\
Gateway=%s\n\
' % (interface['interface'], interface['address'], interface['gateway'])

			for dnsServer in dnsServers:
				interfaceSystemdContent += 'DNS=%s \
' % (dnsServer)
			node_config['networkd']['units'].append({
				'name': '00-%s.network' % (interfaceName),
				'contents': interfaceSystemdContent
			})

		# read content from file if needed for storage.files and systemd.units
		if "storage" in node_config and 'files' in node_config['storage']:
			for file in node_config['storage']['files']:
				if 'contents' in file and 'sourceFile' in file['contents']:
					if not os.path.exists(file['contents']['sourceFile']):
						print('File %s does not exist' % (file['contents']['sourceFile']))
						sys.exit(1)

					with open(file['contents']['sourceFile'], 'r') as stream:
						file['contents'] = stream.read()

		if "systemd" in node_config and 'units' in node_config['systemd']:
			for unit in node_config['systemd']['units']:
				if 'contents' in unit and 'sourceFile' in unit['contents']:
					if not os.path.exists(unit['contents']['sourceFile']):
						print('File %s does not exist' % (unit['contents']['sourceFile']))
						sys.exit(1)

					with open(unit['contents']['sourceFile'], 'r') as stream:
						unit['contents'] = stream.read()


		ignitionJson = json.dumps(node_config, sort_keys=True, indent=2)
		targetFilename = 'ignitions/%s/%s.json' % (args.environment, args.hostname)
		with open(targetFilename, "w") as outfile:
			outfile.write(ignitionJson)
			print('File %s successfully written.' % (targetFilename))

	except yaml.YAMLError as e:
		print('network.yaml has errors: %s' % (e))
		sys.exit(1)

sys.exit(0)





# if not os.path.exists('%s/network.yaml' % (path)):
# 	print('network.yaml does not exist in %s' % (path))
# 	sys.exit(1)

# with open('%s/network.yaml' % (path), 'r') as stream:
#     try:
#         network = yaml.safe_load(stream)
#     except yaml.YAMLError as e:
#     	print('network.yaml has errors: %s' % (e))
#     	sys.exit(1)

# if not os.path.exists('%s/config.yaml' % (path)):
# 	print('config.yaml does not exist in %s' % (path))
# 	sys.exit(1)

# with open('%s/config.yaml' % (path), 'r') as stream:
#     try:
#         config = yaml.safe_load(stream)
#     except yaml.YAMLError as e:
#     	print('config.yaml has errors: %s' % (e))
#     	sys.exit(1)



# users = '"users": ['
# for user, userObject in config['users'].items():
# 	groups = ''
# 	if len(userObject['groups']) > 0:
# 		groups = '"groups": [ "%s" ]' % ('", "'.join(userObject['groups']))
	
# 	comma = ''
# 	if groups:
# 		comma = ','
# 	if 'authorizedKeys' in userObject:
# 		login = '"sshAuthorizedKeys": [ \
# 	      "%s" \
# 	    ]%s' % (userObject['authorizedKeys'], comma)
# 	elif 'passwordHash' in userObject:
# 		login = '"passwordHash": "%s"%s' % (userObject['passwordHash'], comma)

# 	users += ' \
# 	  { \
# 	    "name": "%s", \
# 	    %s, \
# 	    %s \
# 	  }' % (
# 		user,
# 		login,
# 		groups
# 	)

# users += ']'


# print(users)

# ignition = ' \
#     	{ \
#     	  "ignition": { "version": "2.2.0" }, \
#     	  "passwd": { \
#     	    "users": [ \
#     	      { \
#     	        "name": "claudio", \
#     	        "sshAuthorizedKeys": [ \
#     	          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyvOm1lNZQDREfzZyTrR3rFXlqOkcg/gm0qj0Bohi/KSBNrY3Lb2b/7XtAGc6kp4DOYwvyH0I6GxAkQP6heA72OYd3T0sSK/RcMFQHW0DAVTV6CiRhCUV4fKwS57hnZ02sEP3on7gaCD5Mf8gm+zwSoLa+jgZ2MMQrwIz+BcE2rXrMXuPF4QAn9SHSpKA+ja8V/o89Dt4J58awWe3MsccpEnnvkyGoNb82h+Xl96OrCO1Kw5fiuk0LbOs5iVEnxu6rDcU0KFphE4Ggep/BtVPjSwYQDn3fAZ0z3TAUOisi7o+2tY8dq8+AuuvgsUnwpaiUQHpDlxurK5ZQ0/YFzxlVqq1Dm2rk1tuum7xhjimc5HbC5Jq+f7cB9C5MfC7I+uVfjS7PILqY+JEvayTr7C8tYEqD0hF/mmnePLMvTdnL6E5dpkkLKw9DjL3PGpn1KSlspGfY3GRkjzdiMUtrDDym42EflqJn3zAGlm8ZlA2INmOmUgeNr1JJTK2AjycqYIB/GVgG/J6kqf9HaFijGwuSxlyGq3OajKNgtL/WYhpK1O88FXV3rYi03CeG1kdQ3okigibuY+OnKsviUGlOwD+9BHnMnM1exfIYkpflAWI9GxGgFpM7RFuA3Mbag3KeJ0pM7zz+KBPeuSgubVpgpvRe3sIQQ6EWt77kgYk6Ma7C7w== claudio@net-sec.local" \
#     	        ], \
#     	        "groups": [ "sudo", "docker" ] \
#     	      } \
#     	    ] \
#     	  }, \
#     	  "networkd": { \
#     	    "units": [{ \
#     	      "name": "00-enp0s3.network", \
#     	      "contents": "[Match]\nName=enp0s3\n\n[Network]\nAddress=10.20.1.53\nGateway=10.20.1.1\nDNS=8.8.8.8\nDNS=8.8.4.4\n" \
#     	    }] \
#     	  }, \
#     	  "storage": { \
#     	    "files": [{ \
#     	      "filesystem": "root", \
#     	      "path": "/etc/hostname", \
#     	      "mode": 420, \
#     	      "contents": { "source": "data:,coreos-1" } \
#     	    }] \
#     	  }, \
#  \
#     	  "systemd": { \
#     	      "units": [ \
#     	        { \
#     	          "enable": true, \
#     	          "name": "docker" \
#     	        }, \
#     	        { \
#     	          "enable": true, \
#     	          "name": "keepalived", \
#     	          "contents": "" \
#     	        } \
#  \
#  \
#     	      ] \
#     	    } \
#  \
#     	} \
# '



# #pprint(network)
# #pprint(config)
#     	# def __init__(self):
#     	#     self.config = self.defaults.load()
#     	#     if os.path.isfile(self.filename):
#     	#         config = self.parser.load(self.filename)￼ dem schliesse ich mich gerne an :)
#     	#         self.config.update(config)