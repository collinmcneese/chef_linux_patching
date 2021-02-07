# linux_patching

Work-In-Progress for applying Linux OS patches to systems without using an upstream application for locking package versions.

- [linux_patching](#linux_patching)
  - [Supported Platforms](#supported-platforms)
  - [Attributes](#attributes)
    - [Attributes - default](#attributes---default)
    - [Attributes - base_packages](#attributes---base_packages)
    - [Attributes - freeze_packages](#attributes---freeze_packages)
  - [Data Bags](#data-bags)
  - [Helpers](#helpers)
  - [Resources](#resources)
  - [Usage](#usage)

## Supported Platforms

- CentOS
- Fedora
- Red Hat Enterprise Linux
- Oracle Linux
- Amazon Linux
- Ubuntu (Not Yet Implented)
- Debian (Not Yet Implented)
- OpenSuse (Not Yet Implented)

## Attributes

All attributes used by this cookbook are nested under the `linux_patching` key.

### Attributes - default

Default attributes are used in this cookbook to provide values which can be overridden via policy as needed for deployments

```ruby
# Enables verbosity for some of the patching components, disabled by default.
default['linux_patching']['debug'] = false

# Directories which should be present on the system, used by config and patch processes
default['linux_patching']['dirs'] = {
  base: '/path/to/dir',
  logging: '/path/to/dir',
}

# Data bag name to use for item lookups
default['linux_patching']['data_bag'] = 'data_bag_name'
```

### Attributes - base_packages

Used to populate listing of base packages which should exist on systems without a specific version pin.

```ruby
default['linux_patching']['base_packages'] = {
  'platform_name' => {
    'platform_version' => [
      'package',
      'name',
      'array,
    ],
  },
}
```

- __base_packages__ : Base packages are consumed by the `config` recipe to specify packages which should always exist on a system.

### Attributes - freeze_packages

Listing of packages which should be kept at a specified version level, per platform/version.

```ruby
default['linux_patching']['freeze_packages'] = {
  'platform_name' => {
    'platform_version' => [
      # Example:
      # {"package" => "audit-libs.x86_64", "version" => "1.8-2.el5"}
    ],
  },
}
```

## Data Bags

## Helpers

## Resources

## Usage
