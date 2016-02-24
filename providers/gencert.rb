require 'json'
require 'net/http'
require 'openssl'
require 'uri'

use_inline_resources

action :create do
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = body
  res = Net::HTTP.start(uri.hostname, uri.port).request(req)
  data = JSON.parse res.body

  cert = data['result']['certificate']

  write(cert_path, cert)
  write(key_path, key.to_pem)
end

def server
  new_resource.server
end

def uri
  if shared_key
    URI("#{server}/api/v1/cfssl/authsign")
  else
    URI("#{server}/api/v1/cfssl/sign")
  end
end

def body
  body = {
    'certificate_request' => csr,
    'hostname' => hostname,
    'subject' => subject }.to_json
  if shared_key
    token = OpenSSL::HMAC.digest(digest, shared_key, body)
    body = { token: Base64.encode64(token),
             request: Base64.encode64(body) }.to_json
  end
  body
end

def write(filepath, source)
  ::File.open(filepath, 'w') do |file|
    file.write(source)
    file.close_write
  end
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

def subject
  new_resource.subject
end

def hostname
  new_resource.hostname
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
