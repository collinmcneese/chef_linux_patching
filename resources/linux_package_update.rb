# Cookbook:: linux_patching
# Resource:: linux_package_update
#

provides :linux_package_update

description 'Use the **linux_package_update** resource to lookup the listing of available package versions and if the package is installed, update it to the latest version'

property :package_options, String, description: 'Options to pass to the package resource for the update function'
property :use_schedule, [true, false, nil], description: 'Only run the update process during scheduled time for the node.'
property :use_data_bag, [true, false, nil], description: 'Use data_bag item contents as source for list of update packages.'

action :update do
  if new_resource.use_schedule
    # If set to follow schedule, only proceed if the patching window is active
    return unless patch_window_active?()
  end

  if new_resource.use_data_bag
    # When using data bag for source of update listing.
    # Create empty arrays which will be populated with applicable updates
    package_list = []
    arch_list = []
    version_list = []

    # Iterate through available packages using my_update_packages helper method
    my_update_packages.each do |pkg|
      # Package Name and Arch are split with . delimiter.
      pkg_name = pkg['package'].split('.')[0]
      pkg_arch = pkg['package'].split('.')[1]
      # Only add this package to the update list if it is installed on the node with a matching arch
      next unless node['packages'].keys.include? pkg_name
      next unless node['packages'][pkg_name]['arch'] == pkg_arch
      # Display package information in output
      pp pkg
      # Skip updating any package which is in the frozen list
      next if my_frozen_packages.include?(pkg['package'])
      # Update the arrays which will be used to run the `package` resource with any versions from the update list
      package_list << pkg_name
      arch_list << pkg_arch
      version_list << pkg['version']
    end

    package 'install_update_packages' do
      package_name package_list
      version version_list
      arch arch_list
      options new_resource.package_options
      not_if { package_list.empty? }
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
      end
    end
  end
end

action_class do
  # Include custom helpers
  extend LinuxPatching::Helpers
end
