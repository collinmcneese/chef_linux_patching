#
# Cookbook:: linux_patching
# Recipe:: config
#

# Verify that yum components are installed to apply security-only updates on a system
#  EL5, Verify that yum-plugin-security is additionally present
#  %w() is ruby for an array of words
package %w(yum-utils yum-security) do
  action :install
  only_if { %w(redhat centos fedora).include? node['platform'] }
  only_if { node['platform_version'].to_i == 5 }
end

#  EL6, Verify that yum-plugin-security is additionally present
#  %w() is ruby for an array of words
package %w(yum-utils yum-plugin-security) do
  action :install
  only_if { %w(redhat centos fedora).include? node['platform'] }
  only_if { node['platform_version'].to_i == 6 }
end

# EL7+ install additional packages
#  %w() is ruby for an array of words
package %w(yum-utils) do
  action :install
  only_if { %w(redhat centos fedora).include? node['platform'] }
  only_if { node['platform_version'].to_i >= 7 }
end
