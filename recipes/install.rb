#
# Cookbook Name:: cfssl
# Recipe:: server
#

if node['cfssl']['repo']
  repo = node['cfssl']['repo']
  apt_repository 'cfssl' do
    uri repo['uri']
    arch repo['arch']
    distribution repo['distribution']
    components repo['components']
    key repo['key']
  end
end

package 'cfssl' do
  action :install
end
