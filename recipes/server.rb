#
# Cookbook Name:: cfssl
# Recipe:: server
#


include_recipe 'cfssl::install' if node['cfssl']['install']

node['cfssl']['servers'].each do |server, params|
  directory "/etc/#{server}" do
    owner 'root'
    group 'root'
    mode 0700
  end

  directory "/etc/#{server}/certs" do
    owner 'root'
    group 'root'
    mode 0700
  end

  directory "/etc/#{server}/keys" do
    owner 'root'
    group 'root'
    mode 0700
  end

  certs = data_bag_item(node['cfssl']['databag']['name'], server)
  file "#{server} /etc/#{server}/certs/#{server}.pem" do
    path "/etc/#{server}/certs/#{server}.pem"
    content certs['data']['ca']
    mode 0600
  end

  file "#{server} /etc/#{server}/keys/#{server}.pem" do
    path "/etc/#{server}/keys/#{server}.pem"
    content certs['data']['key']
    mode 0600
  end

  if params['csr']
    execute 'initca' do
      cwd "/etc/#{server}"
      command "echo '#{JSON.generate(params['csr'])} | cfssl genkey -initca - | cfssljson -bare ca"
      creates "/etc/#{server}" + "certs/#{server}.pem"
      only_if { params['csr'] }
      notifies :restart, "runit_service[#{server}]"
    end
  end

  file "/etc/#{server}/#{server}.json" do
    owner 'root'
    group 'root'
    mode 0600
    content JSON.pretty_generate(params['config'])
  end

  runit_service server do
    options ({
      :server => server,
      :port => params['port'],
      :config => "/etc/#{server}/#{server}.json",
      :ca => "/etc/#{server}/certs/#{server}.pem",
      :key => "/etc/#{server}/keys/#{server}.pem"
    })
    run_template_name "cfssl"
    log_template_name "cfssl"
    subscribes :restart, "file[/etc/#{server}/#{server}.json]"
  end
end
