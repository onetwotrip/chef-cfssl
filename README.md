# cfssl-cookbook

Provides [cfssl](https://cfssl.org)  server and client LWRP

## Supported Platforms

Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['cfssl']['server']['config']</tt></td>
    <td>Hash</td>
    <td>Main config</td>
  </tr>
  <tr>
    <td><tt>['cfssl']['server']['csr']</tt></td>
    <td>Hash</td>
    <td>Lasyman's CA generation</td>
  </tr>
  <tr>
    <td><tt>['cfssl']['server']['ca']</tt></td>
    <td>String</td>
    <td>Path to CA cert file</td>
  </tr>
  <tr>
    <td><tt>['cfssl']['server']['ca-key']</tt></td>
    <td>String</td>
    <td>Path to CA key file</td>
  </tr>
  <tr>
    <td><tt>['cfssl']['server']['config-file']</tt></td>
    <td>String</td>
    <td>Path to config file on disk</td>
  </tr>
</table>

## Usage

### cfssl::server

Use wrapper cookbook for getting certs in place, pass your config in attribute hash (node['cfssl']['server']['config'])

You can use ['cfssl']['server']['csr'] to have cookbook generate certs for you

### cfssl::client

This recipe demonstrates the use of LWRP cfssl_gencert which is similar to cfssl's subcommand, but allows to use a remote, with HMAC auth
like:
```
cfssl_gencert 'default' do
  action :create
  key_path < where to place new key>
  cert_path < where to place new cert>
  subject <subject for your new cert>
  server <cfssl master server http url>
  shared_key <HMAC preshared key, optional. Enables use of authsign>
end
```

It's totaly up to you how to pass those parameters to gencert - use databags or attributes.

## Todo

 - cfssl profiles
 - more tests
 - circleci integration

## License and Authors

Author:: OneTwoTrip (<smelnik@onetwotrip.com>)
