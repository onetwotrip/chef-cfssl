actions :create, :delete
default_action :create
resource_name :cfssl_gencert

property :key_path, String, required: true
property :cert_path, String, required: true
property :bundle, [TrueClass, FalseClass], required: false, default: true
property :ca_path, String, required: false
property :server, String, required: true
property :profile, String, required: false, default: 'default'
property :hostname, String, required: false, default: nil
property :subject, Hash, required: true
property :owner, [String, Integer], required: false, default: 'root'
property :group, [String, Integer], required: false, default: 'root'
property :mode, [String, Integer], required: false, default: '0600'

# MUST be HEX, enables use of authsign
property :shared_key, kind_of: String, required: false

require 'json'
require 'net/http'
require 'openssl'
require 'uri'

action :create do
  file cert_path do
    action :create
    owner new_resource.owner
    group new_resource.group
    mode '0644'
    content bundle ? [cert, ca].join("\n") : cert
  end

  file key_path do
    action :create
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    sensitive true
    content key.to_pem
  end

  file ca_path do
    action :create
    owner new_resource.owner
    group new_resource.group
    mode '0644'
    content ca
  end
end

def cert
  uri = make_uri(sign_method)
  @cert ||= cfssl_request(uri, body)['result']['certificate'].chomp ||
            Chef::Log.error("Unable to get cert from #{uri}")
end

def ca
  uri = make_uri('info')
  @ca ||= cfssl_request(uri, { label: profile }.to_json)['result']['certificate'].chomp ||
          Chef::Log.error("Unable to get ca from #{uri}")
end

def cfssl_request(uri, request_body)
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = request_body
  res = Net::HTTP.start(uri.hostname, uri.port,
                        use_ssl: uri.scheme == 'https').request(req)
  JSON.parse res.body
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
  token = OpenSSL::HMAC.digest(digest, decoded_shared_key, plain_body)
  { token: Base64.encode64(token), request: Base64.encode64(plain_body) }
end

def key
  @key ||= OpenSSL::PKey::RSA.new ::File.exist?(key_path) ? ::File.read(key_path) : 2048
end

def host_interfaces
  node['network']['interfaces'].select do |_iface_name, data|
    data['addresses']
  end
end

def host_addresses
  addresses = host_interfaces.map do |_name, settings|
    settings['addresses'].keys.select { |k| k.match('\.') }
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

def decoded_shared_key
  return nil unless shared_key
  shared_key.scan(/../).map { |x| x.hex.chr }.join
end

action :delete do
  file key_path do
    action :delete
  end
  file cert_path do
    action :delete
  end
  file ca_path do
    action :delete
  end
end
