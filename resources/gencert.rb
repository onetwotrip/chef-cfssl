actions :create, :delete
default_action :create

attribute :key_path, kind_of: String, required: true
attribute :cert_path, kind_of: String, required: true
attribute :server, kind_of: String, required: true
attribute :hostname, kind_of: String, required: false,
                     default: node['ipaddress']
attribute :subject, kind_of: Hash, required: true

# Should be HEX, enables use of authsign
attribute :shared_key, kind_of: String, required: false

load_current_value do
  if ::File.exist?(cert_path) && ::File.exist?(key_path)
    cert IO.read(cert_path)
    key IO.read(key_path)
  end
end
