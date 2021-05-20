# Cookbook:: linux_patching
# Resource:: linux_package_update
#

resource_name :linux_package_update
provides :linux_package_update

unified_mode true if respond_to?(:unified_mode)

description 'Use the **linux_package_update** resource to lookup the listing of available package versions and if the package is installed, update it to the latest version'

property :package_options, String, description: 'Options to pass to the package resource for the update function'
property :use_schedule, [true, false, nil], description: 'Only run the update process during scheduled time for the node.'
property :use_data_bag, [true, false, nil], description: 'Use data_bag item contents as source for list of update packages.'
property :debug, [true, false, nil], description: 'Include debug output for packages to be updated.'
property :dry_run, [true, false, nil], description: 'Do not apply updates but run through what would be updated.'

action :update do
  if new_resource.use_schedule
    # If set to follow schedule, only proceed if the patching window is active
    return unless patch_window_active?()
  end

  if new_resource.use_data_bag
    # Iterate through available packages using my_update_packages helper method
    my_update_packages.each do |pkg|
      # Package Name and Arch are split with . delimiter.
      pkg_name = pkg['package'].split('.')[0]
      pkg_arch = pkg['package'].split('.')[1]
      # Only add this package to the update list if it is installed on the node with a matching arch
      next unless node['packages'].keys.include? pkg_name
      next unless node['packages'][pkg_name]['arch'] == pkg_arch
      # Display package information in output in debug mode
      if node['linux_patching']['debug'] || new_resource.debug
        puts "Upgrading: #{pkg_name} - #{node['packages'][pkg_name]['version']}-#{node['packages'][pkg_name]['release']} ---> #{pkg_name} - #{pkg['version']}"
      end
      # Skip updating any package which is in the frozen list
      next if my_frozen_packages.include?(pkg['package'])
      # Run upgrade for the package, allowing failure so that update process continues.
      package pkg_name do
        version pkg['version']
        arch pkg_arch
        options new_resource.package_options
        not_if { new_resource.dry_run }
        action :upgrade
        ignore_failure true
      end
    end
  else
    # When not using data bag for source of update listing we will use the built-in package manager to update from our upstream source.
    if %w(ubuntu debian).include? node['platform']
      execute 'apt_update' do
        command <<~APT
        apt update
        apt upgrade -y #{new_resource.package_options}
        APT
        action :run
      end
    end
    if %w(redhat centos fedora oracle).include? node['platform']
      execute 'yum_update' do
        command <<~YUM
        yum check-update
        yum update -y #{new_resource.package_options}
        YUM
        action :run
        only_if 'which yum'
        not_if 'which dnf'
      end
      execute 'dnf_update' do
        command <<~DNF
        dnf check-update
        dnf update -y #{new_resource.package_options}
        DNF
        action :run
        not_if 'which yum'
        only_if 'which dnf'
      end
    end
  end
end

action :cache_refresh do
  if debian?
    apt_update 'name' do
      action :periodic
    end
  elsif fedora_derived?
    execute 'yum_check_update' do
      command 'yum check-update'
      action :run
      returns [0, 100]
      only_if 'which yum'
      not_if 'which dnf'
    end
    execute 'dnf_check-update' do
      command 'dnf check-update'
      action :run
      returns [0, 100]
      only_if 'which dnf'
    end
  end
end

action_class do
  # Include custom helpers
  extend LinuxPatching::Helpers
end
