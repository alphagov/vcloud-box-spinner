require 'spec_helper'
require 'provisioner/errors'
require 'provisioner/provisioner'

describe 'Provisioner::Provisioner' do

  it "should error if credentials not provided" do
    logger = mock(:debug => true, :error => true)
    expect {
      Provisioner::Provisioner.new({:logger => logger}).execute('create')
    }.to raise_error(Provisioner::ConfigurationError,
                     'VCloud credentials must be specified')
  end

  it "should error out if action passed isn't present" do
    logger = mock(:debug => true, :error => true)
    expect {
      Provisioner::Provisioner.new({:logger => logger}).execute('disco')
    }.to raise_error(Provisioner::ConfigurationError,
                     'The action \'disco\' is not a valid action')
  end

end
