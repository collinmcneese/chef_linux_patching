#
# Cookbook:: linux_patching
# Recipe:: update
#

update_options = if redhat_based?
                   '--skip-broken'
                 end

linux_package_update 'apply updates' do
  action :update
  package_options update_options.to_s
  use_schedule true
  use_data_bag true
end
