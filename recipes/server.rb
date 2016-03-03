#
# Cookbook Name:: cfssl
# Recipe:: server
#

include_recipe 'cfssl::install' if node['cfssl']['install']

directory node['cfssl']['server']['config-directory'] do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

execute 'initca' do
  cwd node['cfssl']['server']['config-directory']
  command "echo '#{JSON.generate(node['cfssl']['server']['csr'])}'" \
    ' | cfssl genkey -initca - | cfssljson -bare ca'
  creates node['cfssl']['server']['config-directory'] + 'ca.pem'
  not_if node['cfssl']['server']['csr'].nil?
end

include_recipe 'runit'

file node['cfssl']['server']['config-file'] do
  action :create
  owner 'root'
  group 'root'
  mode '0600'
  path node['cfssl']['server']['config-file']
  content JSON.pretty_generate(node['cfssl']['server']['config'])
end

runit_service 'cfssl' do
  restart_on_update true
  subscribes :restart, "file[#{node['cfssl']['server']['config-file']}]"
end
