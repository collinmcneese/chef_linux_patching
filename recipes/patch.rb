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

patch_options = node['linux_patching']['patch_run']['default']

linux_package_update 'apply updates' do
  action :update
  package_options update_options.to_s
  use_schedule patch_options['use_schedule']
  use_data_bag patch_options['use_data_bag']
  notifies :run, 'inspec_exec[pre_patch]', :before
  notifies :run, 'inspec_exec[post_patch]', :immediately
end

inspec_exec 'post_patch' do
  path "#{base_dir()}/test/pre_patch"
  save_results true
  action :nothing
end
