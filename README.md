# vCloud Provisioner

This is a wrapper around the vCloud director API that should allow for easy
provisioning of VMs. It's a bit of a mess at the moment. Hopefully that will
improve over time.

## Usage

To provision a machine you will need to specify at least two JSON files:

  1. A JSON config file which tells the provisioner about the vCloud
     organisation into which it is to provision a vApp
  2. A JSON config file which defines the machine-specific setup

The best way to understand the format of these files is probably by example.
See [the deployment repository](https://github.com/alphagov/deployment) for
numerous examples.

Once you have an org and machine config, you can invoke the provisioner as
follows:

    bundle exec bin/provision org_config.json machine_config.json

In all likelihood, you should set a few of the command line options too. In
particular, make sure you correctly specify the name of your user on the
Puppet master (the `-s` option).

See `bundle exec bin/provision --help` for a full list of available options.

## Hacking

### Testing

You can run the tests with:

    bundle exec rake

### Changing puppetmaster & puppetclient scripts

Depending on the roles assigned in json in vcloud-templates,
vcloud-provisioner chooses the puppetmaster.sh or puppetclient.sh
scripts to run on the client. Though you would be running bin/provision
command from your local box, it would not be using these scripts from
your local boxes, rather it would be downloading this from S3
(gds-public-readable-tarballs bucket). So if you would be making changes
to these scripts you need to upload them to S3 after making changes.
