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

end
