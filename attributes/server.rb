default['cfssl']['packages'] = ["github.com/cloudflare/cfssl/cmd/cfssl"]
default['cfssl']['databag']['name'] = 'cfssl'

default['cfssl']['servers']['cfssl']['config'] = nil
default['cfssl']['servers']['cfssl']['port'] = 8888
default['cfssl']['servers']['cfssl']['csr'] = nil
