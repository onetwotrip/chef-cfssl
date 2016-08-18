default['cfssl']['server']['config'] = nil

default['cfssl']['server']['ca'] = '/etc/cfssl/ca.pem'
default['cfssl']['server']['ca-key'] = '/etc/cfssl/ca-key.pem'
default['cfssl']['server']['config-file'] = '/etc/cfssl/config.json'
default['cfssl']['server']['config-directory'] = '/etc/cfssl/'
default['cfssl']['server']['runit']['service'] = 'cfssl'
default['cfssl']['server']['runit']['cookbook'] = 'cfssl'

default['cfssl']['server']['csr'] = nil
