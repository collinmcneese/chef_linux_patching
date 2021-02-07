#
# Cookbook:: linux_patching
# Inspec Test:: pre_patch_default_test
#

describe directory('/tmp') do
  it { should exist }
end
