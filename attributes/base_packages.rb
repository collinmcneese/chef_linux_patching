# rubocop:disable Style/WordArray
# Used to populate listing of base packages which should exist on systems
default['linux_patching']['base_packages'] = {
  'centos' => {
    5 => [
      'audit',
      'nfs-utils',
    ],
    6 => [
      'audit',
      'nfs-utils',
    ],
    7 => [
      'audit',
      'nfs-utils',
    ],
    8 => [
      'audit',
      'nfs-utils',
    ],
  },
}
