# Enables verbosity for some of the patching components, disabled by default.
default['linux_patching']['debug'] = false

# Directories which should be present on the system, used by config and patch processes
default['linux_patching']['dirs'] = {
  base: '/var/linux_patching_cookbook',
  logging: '/var/linux_patching_cookbook/logs',
}
