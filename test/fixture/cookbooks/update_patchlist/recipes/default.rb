# Cookbook:: update_patchlist
# Recipe:: default
# Used to update data_bag items in linux_patching data_bag with the latest available packages for platforms

# Checks for latest available update packages and saves either to local path (if using kitchen-dokken) or
#  to data bag location (if attribute `node['linux_patching_updates']['data_bag_upload']` is `true`)

include_recipe 'linux_patching::config'

cache_path = ::Chef::Config[:file_cache_path]

data_bag_name = 'linux_patching_stage'
data_bag_path = "/data_bags/#{data_bag_name}"
data_bag_item = "updates-#{node['platform']}-#{node['platform_version'].to_i}"

directory data_bag_path do
  action :create
  only_if { Dir.exist?('/data_bags') }
end

ruby_block 'update_list_create' do
  block do
    if Dir.exist?(data_bag_path) || node['linux_patching_updates']['data_bag_upload']
      if %w(redhat centos fedora oracle).include? node['platform']
        # Fetch the list of currently installed packages using some tr/sed to account for long package names and yum output wrapping
        available_list = shell_out('yum -q list available | tr "\\n" "#" | sed -e \'s/# / /g\' | tr "#" "\n"').stdout.split(/\n/)
        return_array = []
        available_list.each do |row|
          # Only act on the rows which are package versions and not other yum output
          if row =~ /.*\..*[0-9]/
            return_array << { 'package' => row.split()[0].strip(), 'version' => row.split()[1].strip() }
          end
        end
        # File.write("#{data_bag_path}/#{data_bag_item}.json", return_array.to_json)
        node.run_state['linux_patching_updates'] = {
          'id' => "#{data_bag_item}",
          'version' => "#{::Time.now.to_i}",
          'packages' => return_array,
        }
      elsif %w(ubuntu debian).include? node['platform']
        available_list = shell_out('apt list available | tr "\\n" "#" | sed -e \'s/# / /g\' | tr "#" "\n"').stdout.split(/\n/)
        return_array = []
        available_list.each do |row|
          # Only act on the rows which are package versions and not other apt output
          if row =~ %r{.*/.*[0-9]}
            return_array << { 'package' => row.split()[0].split('/')[0].strip(), 'version' => row.split()[1].strip() }
          end
        end
        # File.write("#{data_bag_path}/#{data_bag_item}.json", return_array.to_json)
        node.run_state['linux_patching_updates'] = {
          'id' => "#{data_bag_item}",
          'version' => "#{::Time.now.to_i}",
          'packages' => return_array,
        }
      end
    else
      puts 'Could not find the /data_bags directory'
    end
  end
  action :run
end

# If using kitchen-dokken, save output to `data_bag_path`
file "#{data_bag_path}/#{data_bag_item}.json" do
  content lazy { node.run_state['linux_patching_updates'].to_json }
  only_if { Dir.exist?(data_bag_path) }
  sensitive true
  not_if { node['linux_patching_updates']['data_bag_upload'] }
end

# Upload contents to staging databag on Chef Infra server

# Configure knife
chef_server_url = ENV['CHEF_INFRA_SERVER_URL'] || ''
knife_user = ENV['KNIFE_USER'] || ''
knife_pem = ENV['KNIFE_PEM'] || ''

directory "#{cache_path}/.chef" do
  action :create
  only_if { node['linux_patching_updates']['data_bag_upload'] }
end

knife_cfg = "#{cache_path}/.chef/knife.rb"

file knife_cfg do
  content <<~CFGFILE
  log_level                :info
  log_location             STDOUT
  node_name                "#{knife_user}"
  client_key               "#{cache_path}/.chef/knife.pem"
  chef_server_url          "#{chef_server_url}"
  CFGFILE
  action :create
  only_if { node['linux_patching_updates']['data_bag_upload'] }
end

file "#{cache_path}/.chef/knife.pem" do
  content knife_pem
  action :create
  only_if { node['linux_patching_updates']['data_bag_upload'] }
end

# Write out patch list to JSON file
json_output_file = "#{cache_path}/#{data_bag_item}.json"
file json_output_file do
  content lazy { node.run_state['linux_patching_updates'].to_json }
  only_if { Dir.exist?(data_bag_path) }
  sensitive true
  only_if { node['linux_patching_updates']['data_bag_upload'] }
end

# Upload data bag to Chef Infra server
ruby_block "upload #{data_bag_item}" do
  block do
    puts
    puts node.run_state['linux_patching_updates']['version']
    shell_out("/opt/chef/bin/knife -c #{knife_cfg} data bag from file #{data_bag_name} #{json_output_file}")
  end
  action :run
  only_if { node['linux_patching_updates']['data_bag_upload'] }
  only_if { ::File.exist?(json_output_file) }
end
