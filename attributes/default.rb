# Enrollment status, cookbook logic will not process node is enrolled
default['linux_patching']['enrollment'] = true

# Enables verbosity for some of the patching components, disabled by default.
default['linux_patching']['debug'] = false

# Directories which should be present on the system, used by config and patch processes
default['linux_patching']['dirs'] = {
  base: '/var/linux_patching_cookbook',
  logging: '/var/linux_patching_cookbook/logs',
}

# Data bag name to use for item lookups
default['linux_patching']['data_bag'] = 'linux_patching'

# Set the patch properties via attributes so that they can be easily targeted via policy
default['linux_patching']['patch_run']['default'] = {
  use_schedule: false,
  use_data_bag: true,
}
