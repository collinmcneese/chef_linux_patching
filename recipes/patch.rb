#
# Cookbook:: linux_patching
# Recipe:: update
#

linux_package_update 'refresh' do
  action :cache_refresh
end

inspec_exec 'pre_patch' do
  path "#{base_dir()}/test/pre_patch"
  save_results true
  action :nothing
end

update_options = if redhat_based?
                   '--skip-broken'
                 end

linux_package_update 'apply updates' do
  action :update
  package_options update_options.to_s
  use_schedule true
  use_data_bag true
  notifies :run, 'inspec_exec[pre_patch]', :before
  notifies :run, 'inspec_exec[post_patch]', :immediately
end

inspec_exec 'post_patch' do
  path "#{base_dir()}/test/pre_patch"
  save_results true
  action :nothing
end
