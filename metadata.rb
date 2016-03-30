name             'cfssl'
maintainer       'OneTwoTrip Team'
maintainer_email 'operations@onetwotrip.com'
license          'LGPLv3'
description      'Installs/Configures cfssl'
long_description 'Installs/Configures cfssl'
version          '0.2.0'

issues_url       'https://github.com/onetwotrip/chef-cfssl/issues'
source_url       'https://github.com/onetwotrip/chef-cfssl'

chef_version ">= 12.0" if respond_to?(:chef_version)
supports 'ubuntu'

depends 'apt'
depends 'runit'
