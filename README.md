# linux_patching

Work-In-Progress for applying Linux OS patches to systems without using an upstream application for locking package versions.

- [linux_patching](#linux_patching)
  - [Supported Platforms](#supported-platforms)
  - [Attributes](#attributes)
    - [Attributes - base_packages](#attributes---base_packages)
    - [Attributes - freeze_packages](#attributes---freeze_packages)
    - [Attributes - updates_packages](#attributes---updates_packages)
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

### Attributes - updates_packages

Data bag name to use for item lookups.

```ruby
default['linux_patching']['update_packages']['data_bag'] = 'data_bag_name'
```

## Data Bags

## Helpers

## Resources

## Usage
