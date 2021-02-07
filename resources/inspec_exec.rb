# Cookbook:: linux_patching
# Resource:: inspec_exec
#

provides :inspec_exec

description 'Use the **inspec_exec** resource to execute Chef Inspec tests from within the cookbook'

property :path, String, name_property: true, description: 'Options to pass to the package resource for the update function.'
property :inspec_exec, String, description: 'Optional path to specify source of the Inspec executable.'
property :save_results, [true, false, nil], default: true, description: 'Results should be saved to local filesystem.'
property :results_path, String, description: 'Location to save result files.'

action :run do
  # Find the path to the Inspec executable on the system
  # Use the provided path, if available
  inspec_bin = if new_resource.inspec_exec && ::File.exist?(new_resource.inspec_exec)
                 new_resource.inspec_exec
               elsif ::File.exist?('/opt/chef/bin/inspec')
                 '/opt/chef/bin/inspec'
               elsif ::File.exist?('/opt/chef-workstation/bin/inspec')
                 '/opt/chef-workstation/bin/inspec'
               end

  raise 'Could not find the Inspec executable' unless !inspec_bin.nil?
  log "Using Inspec binary located at: #{inspec_bin}"

  results_path = new_resource.results_path || log_dir()
  results = if new_resource.save_results
              " --reporter=yaml:#{results_path}/#{new_resource.path.split('/').join('_')}.yml"
            end

  execute 'inspec_exec' do
    command <<~INSPEC
    #{inspec_bin} exec #{new_resource.path} #{results}
    INSPEC
    action :run
  end
end

action_class do
  # Include custom helpers
  extend LinuxPatching::Helpers
end
