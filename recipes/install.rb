#
# Cookbook Name:: cfssl
# Recipe:: server
#

include_recipe "build-essential"
include_recipe "golang"

node['cfssl']['packages'].each do |go_pak|
  golang_package go_pak
end
