# encoding: utf-8
require 'inspec'

# use basic tests
describe package('cfssl') do
  it { should be_installed }
end

describe command('cat /tmp/cert.pem | cfssl certinfo -cert -') do
  its(:stdout) { should match(/"country": "US"/) }
end
