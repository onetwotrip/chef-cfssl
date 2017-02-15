default['cfssl']['repo'] = {
  uri: 'https://dl.bintray.com/onetwotrip/cfssl',
  arch: 'amd64',
  distribution: 'trusty',
  components: ['main'],
  key: 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray',
}
default['cfssl']['install'] = true

