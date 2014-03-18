This project is no longer under active development. Please take a look at [vCloud Tools](https://github.com/alphagov/vcloud-tools).

# vCloud Box Spinner

This is a wrapper around the vCloud director API that should allow for easy
provisioning of VMs.

## Installation

    gem install vcloud-box-spinner

## Usage

You should be able to do `vcloud-box-spinner --help`

    Usage: vcloud-box-spinner [options] <org_config> <machine_config>

    Provision a machine described by the JSON template `machine_config` in the vCloud organisation
    described in the JSON config file `org_config`

    e.g. vcloud-box-spinner -u username orgs/staging.json machines/frontend-1.json

        -c, --credential=GROUP           fog credential group
        -u, --user=USERNAME              vCloud username
        -p, --password=PASSWORD          vCloud password
        -F, --ssh-config=FILENAME        SSH config file(s) to use (can be specified multiple times)
        -s, --setup-script=SETUP-SCRIPT  path to setup script that should run after machine is brought up
        -d, --debug                      Enable debugging output
        -v, --verbose                    Enable verbose output
        -h, --help                       Show usage instructions

To provision a machine you will need to specify at least two JSON files:

  1. A JSON config file which tells the provisioner about the vCloud
     organisation into which it is to provision a vApp
  2. A JSON config file which defines the machine-specific setup

Options:

  - `user` is the username on your "vmware vcloud director" page
    (usually in the top right corner).
  - `setup-script` allows you to pass a script file path (shell), which
    would be loaded as guest customization script. The purpose of
    providing this option, is to let user do some basic bootstraping.
    The script is not for the purpose of encouraging configuration
    management and that should be done separately. A particular example
    of how you can use the script is - You can set ssh configuration for
    a user(eg ci), which can ssh in the system later and run the config
    management script/tool.
    On how to write this script please refer the following links:

      - [Understand Guest OS Customisation](http://pubs.vmware.com/vcd-51/index.jsp?topic=%2Fcom.vmware.vcloud.users.doc_51%2FGUID-BB682E4D-DCD7-4936-A665-0B0FBD6F0EB5.html)
      - [Example of scripts](http://pubs.vmware.com/vcd-51/index.jsp?topic=%2Fcom.vmware.vcloud.users.doc_51%2FGUID-724EB7B5-5C97-4A2F-897F-B27F1D4226C7.html)

The best way to understand the formats of the json files, read the docs
[here](/docs/json_formats.md)

Once you have an org and machine config, you can invoke the provisioner as
follows:

    vcloud-box-spinner -u username -p password org_config.json machine_config.json

## Environment Variables

  - `FOG_RC` specifies the fog credentials file if not `~/.fog`.
  - `FOG_CREDENTIAL` specifies the credential group if not `default`.

## Hacking

refer [here](/docs/hacking.md)

### Testing

You can run the tests with:

    bundle exec rake
