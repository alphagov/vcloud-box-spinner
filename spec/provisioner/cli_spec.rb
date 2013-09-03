require 'spec_helper'
require 'provisioner/cli'

MACHINE_METADATA = {
# :puppetmaster => 'foo.bar.baz',
  :zone         => 'foo',
# :catalog_id   => 'default_catalog_id',
}.freeze

DEFAULTS = {
  :debug       => false,
  :log_level   => 5,
  :memory      => 4096,
  :num_cores   => 2,
  :num_servers => 1,
  :platform    => "production",
  :ssh_config  => true,         # if not specified, use system defaults
}

describe Provisioner::CLI do
  describe "#defaults" do
    Provisioner::CLI.defaults.should ==  DEFAULTS
  end

  describe "#process" do
    it 'should set options from built-in defaults' do
      options = { :machine_metadata => MACHINE_METADATA,
                  :org_config => {} }
      res = Provisioner::CLI.process(options)
      res.should include(DEFAULTS)
    end

    it 'should set options from the vCloud config defaults' do
      config = { :default => { :ip => '5.6.7.8' } }
      res = Provisioner::CLI.process({:machine_metadata => MACHINE_METADATA,
                                      :org_config => config})
      res.should include(:ip => '5.6.7.8')
    end

    it 'should set options from the vCloud config based on the specified zone' do
      config = { :foo => { :ip => '9.8.7.6' } }
      res = Provisioner::CLI.process({:org_config => config,
                                      :machine_metadata => MACHINE_METADATA})
      res.should include(:ip => '9.8.7.6')
    end

    it 'should set options from the machine template' do
      options = { :machine_metadata => MACHINE_METADATA.dup.merge( :ip => '1.2.3.4' ),
                  :org_config => {} }
      res = Provisioner::CLI.process(options)
      res.should include(:ip => '1.2.3.4')
    end

    it 'should set options from the command line' do
      opts = {:ssh_user => 'donald',
              :org_config => {},
              :machine_metadata => MACHINE_METADATA }
      res = Provisioner::CLI.process(opts)
      res.should include(:ssh_user => 'donald')
    end

    it 'should override vCloud config defaults with vCloud zone defaults' do
      config = {
        :default => { :ip => '1.2.3.4' },
        :foo => { :ip => '5.6.7.8' }
      }
      res = Provisioner::CLI.process({:org_config => config,
                                      :machine_metadata => MACHINE_METADATA})
      res.should include(:ip => '5.6.7.8')
    end

    it 'should override vCloud zone defaults with machine template options' do
      options = { :org_config => { :foo => { :ip => '1.2.3.4' } },
                  :machine_metadata => MACHINE_METADATA.dup.merge(:ip => '5.6.7.8')}
      res = Provisioner::CLI.process(options)
      res.should include(:ip => '5.6.7.8')
    end

    it 'should override machine template options with command line options' do
      options = { :machine_metadata => MACHINE_METADATA.dup.
                      merge(:ssh_user => 'aaron'),
                  :org_config => {},
                  :ssh_user => 'binky' }
      res = Provisioner::CLI.process(options)
      res.should include(:ssh_user => 'binky')
    end

    it 'should require a zone to be set' do
      tpl = MACHINE_METADATA.dup
      tpl.delete(:zone)
      expect do
        Provisioner::CLI.process({:machine_metadata => tpl})
      end.to raise_error(Provisioner::ConfigurationError, /zone/)
    end

  end

  describe "#execute" do
    before :each do silence_output end
    after :each do silence_output end

    it "should fail if two arguments not provided" do
      expect {
        Provisioner::CLI.new(['-u' , 'user', '-p', 'pass']).execute
      }.to raise_error(SystemExit)
    end

    it "should call provision a machine" do
      default_org_config =
        { :template_name => "template-name",
          :host=>"api-end-host",
          :platform=>"qa",
          :organisation=>"org-name",
          }
        zone_org_config =
          { :domain => "tester.default",
            :network_name => "Default",
            :vdc_name=>"vdc-name" }
        machine_metadata = { :zone => "tester",
                             :vm_name => "machine-2",
                             :ip => "192.168.2.2" }
        expected_opts = DEFAULTS.merge(default_org_config).
          merge(zone_org_config).
          merge(machine_metadata).
          merge({ :user => 'badger', :password => 'eggplant' })

      VcloudBoxProvisioner.should_receive(:build).
        with(expected_opts).
        and_return(mock(:execute => true))

      cli = Provisioner::CLI.new(['-u', 'badger', '-p', 'eggplant',
                                  '-o', 'spec/test_data/org.json',
                                  '-m', 'spec/test_data/machine.json',
                                  'create'
                                ])
      cli.execute
    end
  end

end
