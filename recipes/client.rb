# This is just an exaple, do not use in production

cfssl_gencert 'default' do
  action :create
  key_path node['cfssl']['client']['key']
  cert_path node['cfssl']['client']['cert']
  ca_path node['cfssl']['client']['ca']
  subject node['cfssl']['client']['subject']
  server node['cfssl']['client']['server_url']
  shared_key node['cfssl']['client']['shared_key']
end
