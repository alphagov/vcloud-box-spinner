require 'spec_helper'
require 'gds/provisioner/cli'

MOCK_TEMPLATE = {
  :puppetmaster => 'foo.bar.baz',
  :zone         => 'foo',
  :catalog_id   => 'default_catalog_id',
}.freeze

describe Gds::Provisioner::CLI do

  it 'should set options from built-in defaults' do
    res = Gds::Provisioner::CLI.process({}, MOCK_TEMPLATE)
    res.should include(:role)
  end

  it 'should set options from the vCloud config defaults' do
    config = { :default => { :ip => '5.6.7.8' } }
    res = Gds::Provisioner::CLI.process(config, MOCK_TEMPLATE)
    res.should include(:ip => '5.6.7.8')
  end

  it 'should set options from the vCloud config based on the specified zone' do
    config = { :foo => { :ip => '9.8.7.6' } }
    res = Gds::Provisioner::CLI.process(config, MOCK_TEMPLATE)
    res.should include(:ip => '9.8.7.6')
  end

  it 'should set options from the machine template' do
    tpl = MOCK_TEMPLATE.dup
    tpl[:ip] = '1.2.3.4'
    res = Gds::Provisioner::CLI.process({}, tpl)
    res.should include(:ip => '1.2.3.4')
  end

  it 'should set options from the command line' do
    opts = {:ssh_user => 'donald'}
    res = Gds::Provisioner::CLI.process({}, MOCK_TEMPLATE, opts)
    res.should include(:ssh_user => 'donald')
  end

  it 'should override vCloud config defaults with vCloud zone defaults' do
    config = {
      :default => { :ip => '1.2.3.4' },
      :foo => { :ip => '5.6.7.8' }
    }
    res = Gds::Provisioner::CLI.process(config, MOCK_TEMPLATE)
    res.should include(:ip => '5.6.7.8')
  end

  it 'should override vCloud zone defaults with machine template options' do
    config = { :foo => { :ip => '1.2.3.4' } }
    tpl = MOCK_TEMPLATE.dup
    tpl[:ip] = '5.6.7.8'
    res = Gds::Provisioner::CLI.process(config, tpl)
    res.should include(:ip => '5.6.7.8')
  end

  it 'should override machine template options with command line options' do
    tpl = MOCK_TEMPLATE.dup
    tpl[:ssh_user] = 'aaron'
    opts = { :ssh_user => 'binky' }
    res = Gds::Provisioner::CLI.process({}, MOCK_TEMPLATE, opts)
    res.should include(:ssh_user => 'binky')
  end

  it 'should use catalog_id if present' do
    tpl = MOCK_TEMPLATE.dup
    tpl.merge!(
      :catalog_id => 'wibble',
      :catalog_items => { :my_cool_template => 'incorrect' },
      :template_name => 'my_cool_template'
    )
    res = Gds::Provisioner::CLI.process({}, tpl)
    res.should include(:catalog_id => 'wibble')
  end

  it 'should use template_name to determine catalog_id if catalog_id not present' do
    tpl = MOCK_TEMPLATE.dup
    tpl.delete(:catalog_id)
    tpl.merge!(
      :catalog_items => { :my_cool_template => 'https://correct_catalog_id' },
      :template_name => 'my_cool_template'
    )
    res = Gds::Provisioner::CLI.process({}, tpl)
    res.should include(:catalog_id => 'https://correct_catalog_id')
  end

  it 'should require a zone to be set' do
    tpl = MOCK_TEMPLATE.dup
    tpl.delete(:zone)
    expect do
      Gds::Provisioner::CLI.process({}, tpl)
    end.to raise_error(Gds::Provisioner::ConfigurationError, /zone/)
  end

  it 'should require a puppetmaster to be set' do
    tpl = MOCK_TEMPLATE.dup
    tpl.delete(:puppetmaster)
    expect do
      Gds::Provisioner::CLI.process({}, tpl)
    end.to raise_error(Gds::Provisioner::ConfigurationError, /puppetmaster/)
  end

end
