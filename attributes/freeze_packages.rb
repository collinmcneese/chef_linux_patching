# rubocop:disable Style/WordArray
# Listing of packages which should be kept at a specified version level, per platform/version
#
default['linux_patching']['freeze_packages'] = {
  'centos' => {
    5 => [
      # Example:
      # {"package" => "audit-libs.x86_64", "version" => "1.8-2.el5"}
    ],
    6 => [],
    7 => [],
    8 => [],
  },
}
