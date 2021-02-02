#
# Cookbook:: linux_patching
# Recipe:: default
#

include_recipe 'linux_patching::config'
include_recipe 'linux_patching::baseline'
include_recipe 'linux_patching::patch'
