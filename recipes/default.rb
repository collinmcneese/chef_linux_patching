#
# Cookbook:: linux_patching
# Recipe:: default
#

log 'enrollment_status' do
  level :info
  message 'System is not currently enrolled for patching process.'
  not_if { node['linux_patching']['enrollment'] }
end

include_recipe 'linux_patching::config' if node['linux_patching']['enrollment']
include_recipe 'linux_patching::patch' if node['linux_patching']['enrollment']
