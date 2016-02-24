default['cfssl']['server']['config'] = {
  'signing' => {
    'default' => {
      'usages' => [
        'any'
      ],
      'expiry' => '10h',
      'auth_key' => 'ca-auth'

    }
  },
  'auth_keys' => {
    'ca-auth' => {
      'type' => 'standard',
      'key' => '0123456789ABCDEF0123456789ABCDEF'
    }
  }
}

default['cfssl']['server']['ca'] = '/etc/cfssl/ca.pem'
default['cfssl']['server']['ca-key'] = '/etc/cfssl/ca-key.pem'
default['cfssl']['server']['config-file'] = '/etc/cfssl/config.json'
default['cfssl']['server']['config-directory'] = '/etc/cfssl/'

default['cfssl']['server']['csr'] = nil
