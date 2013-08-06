# vCloud Provisioner

This is a wrapper around the vCloud director API that should allow for easy
provisioning of VMs.

## Installation

    gem install vcloud_network_configurator

* Note: It is work in progress, and currently you would have to build
  them gem locally using the following commands

      git clone git@github.gds:gds/vcloud-box-configurator
      gem build vcloud-box-configurator.gemspec
      gem install ./vcloud-box-configurator-0.1.0.gem

## Usage

You should be able to do `vcloud-box-provisioner --help`

    Usage: vcloud-box-provisioner [options] <org_config> <machine_config>

    Provision a machine described by the JSON template `machine_config` in the vCloud organisation
    described in the JSON config file `org_config`

    e.g. vcloud-box-provisioner -u username orgs/staging.json machines/frontend-1.json

        -u, --user=USERNAME              vCloud username
        -p, --password=PASSWORD          vCloud password
        -F, --ssh-config=FILENAME        SSH config file(s) to use (can be specified multiple times)
        -d, --debug                      Enable debugging output
        -v, --verbose                    Enable verbose output
        -h, --help                       Show usage instructions

To provision a machine you will need to specify at least two JSON files:

  1. A JSON config file which tells the provisioner about the vCloud
     organisation into which it is to provision a vApp
  2. A JSON config file which defines the machine-specific setup

The best way to understand the formats of the json files, read the docs
[here](/docs/json_formats.md)

Once you have an org and machine config, you can invoke the provisioner as
follows:

    vcloud-box-provisioner -u username -p password org_config.json machine_config.json

## Hacking

refer [here](/docs/hacking.md)

### Testing

You can run the tests with:

    bundle exec rake
