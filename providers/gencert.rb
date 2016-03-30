require 'json'
require 'net/http'
require 'openssl'
require 'uri'

use_inline_resources

action :create do
  uri = make_uri(sign_method)
  cert = cfssl_request(uri, body)['result']['certificate'] ||
         Chef::Log.error("Unable to get cert from #{uri}")

  uri = make_uri('info')
  ca = cfssl_request(uri, { label: profile }.to_json)['result']['certificate']

  file "#{subject}.cert" do
    action :create
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
    path cert_path
    content bundle ? cert + ca : cert
  end

  file "#{subject}.key" do
    action :create
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
    path key_path
    content key.to_pem
  end

  file "#{subject}.ca.cert" do
    action :create
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
    path ca_path
    content ca
  end
end

def cfssl_request(uri, request_body)
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = request_body
  res = Net::HTTP.start(uri.hostname, uri.port,
    :use_ssl => uri.scheme == 'https').request(req)
  JSON.parse res.body
end

def server
  new_resource.server
end

def make_uri(method)
  URI("#{server}/api/v1/cfssl/#{method}")
end

def sign_method
  shared_key ? 'authsign' : 'sign'
end

def body
  body = {
    'certificate_request' => csr,
    'profile' => profile,
    'subject' => subject }
  body['hosts'] = hostname ? [hostname] : host_addresses
  body = encrypt(body.to_json) if shared_key
  body.to_json
end

def encrypt(plain_body)
  token = OpenSSL::HMAC.digest(digest, shared_key, plain_body)
  { token: Base64.encode64(token), request: Base64.encode64(plain_body) }
end

def key
  @key ||= OpenSSL::PKey::RSA.new 2048
end

def key_path
  new_resource.key_path
end

def cert_path
  new_resource.cert_path
end

def ca_path
  new_resource.ca_path
end

def subject
  new_resource.subject
end

def profile
  new_resource.profile
end

def hostname
  new_resource.hostname
end

def bundle
  new_resource.bundle
end

def host_addresses
  addresses = node['network']['interfaces'].keys.map do |iface_name|
    node['network']['interfaces'][iface_name]['addresses'].keys.select do |k|
      k.match('\.')
    end
  end
  addresses.flatten!
end

def csr
  request = OpenSSL::X509::Request.new
  request.public_key = key.public_key
  request.sign key, OpenSSL::Digest::SHA256.new
  request.to_pem
end

def digest
  OpenSSL::Digest.new('sha256')
end

def shared_key
  if new_resource.shared_key
    new_resource.shared_key.scan(/../).map { |x| x.hex.chr }.join
  end
end

action :delete do
  file key_path do
    action delete
  end
  file cert_path do
    action delete
  end
end
