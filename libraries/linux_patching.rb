# Cookbook:: linux_patching
# Library:: linux_patching
#

module LinuxPatching
  module Helpers
    def my_baseline_packages
      node['linux_patching']['base_packages']["#{node['platform']}"][node['platform_version'].to_i]
    rescue
      Chef::Log.warn('Unable to determine baseline packages using my_baseline_packages helper method.')
      []
    end

    def my_frozen_packages
      # Return list of frozen package names
      node['linux_patching']['freeze_packages']["#{node['platform']}"][node['platform_version'].to_i].map { |p| p['package'] }
    rescue
      Chef::Log.warn('Unable to determine frozen packages using my_frozen_packages helper method.')
      []
    end

    def my_update_packages
      # Get list of available packages from Data Bag
      data_bag_item(node['linux_patching']['data_bag'], "updates-#{node['platform']}-#{node['platform_version'].to_i}")['packages']
    rescue
      Chef::Log.warn('Unable to determine update packages using my_update_packages helper method.')
      []
    end

    def base_dir
      node['linux_patching']['dirs']['base']
    end

    def log_dir
      node['linux_patching']['dirs']['logging']
    end

    def patch_window_active?
      # Fetch schedule data from data_bag
      bag_data = data_bag_item(node['linux_patching']['data_bag'], 'schedule')
      # Use the data for this node's policy_group
      if bag_data["#{node['policy_group']}"]
        schedule = bag_data["#{node['policy_group']}"]
        # See if the current (now) time is in the patch window
        if ::DateTime.now() >= ::DateTime.parse("#{schedule['date']} #{schedule['start_hour']}") &&
           ::DateTime.now() <= ::DateTime.parse("#{schedule['date']} #{schedule['end_hour']}")
          puts ' Patching window is currently active!'
          # Return a value of true if patching window is active
          true
        else
          puts ' No patching window active.'
          false
        end
      end
    end
  end
end

Chef::DSL::Recipe.include LinuxPatching::Helpers
Chef::Resource.include LinuxPatching::Helpers
