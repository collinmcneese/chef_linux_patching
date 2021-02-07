#
# Cookbook:: linux_patching
# Recipe:: config
#

# Install baseline packages
package my_baseline_packages()

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

# Verify that configured directories are present.
directory base_dir() do
  owner 'root'
  group 'root'
  mode '0750'
  recursive true
end

directory log_dir() do
  owner 'root'
  group 'root'
  mode '0750'
  recursive true
end

remote_directory "#{base_dir()}/test" do
  source 'test'
  owner 'root'
  group 'root'
  mode '0750'
end
