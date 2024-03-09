#
# Cookbook:: voidworks
# Recipe:: ipaconfig
#
# Copyright:: 2024, The Authors, All Rights Reserved.

# Retrieve Password from encrypted Databag
ipa_secret = Chef::EncryptedDataBagItem.load_secret("/etc/chef/encrypted_data_bag_secret")
ipa_credentials = Chef::EncryptedDataBagItem.load("ipa", "secret", ipa_secret)

# First, ensure the client package is installed
package 'ipa-client'

# Join the IPA domain
execute 'join_ipa_domain' do
  command "ipa-client-install --unattended --principal=admin --password=#{ipa_password} --domain=voidworks.cc --realm=VOIDWORKS.cc --hostname=$(hostname -f) --mkhomedir"
  action :run
  not_if { ::File.exist?('/etc/ipa/default.conf') } # Prevents rejoining if already joined
  sensitive true # This ensures that the command output is suppressed in Chef logs
end

# Ensure the SSSD service is enabled and started
service 'sssd' do
  action [:enable, :start]
end
