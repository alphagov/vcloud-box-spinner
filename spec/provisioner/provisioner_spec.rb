require 'spec_helper'
require 'provisioner/errors'
require 'provisioner/provisioner'

shared_examples "validate credentials" do |action|
  it "should error if credentials not provided while perfoming #{action}" do
    logger = mock(:debug => true, :error => true)
    expect {
      Provisioner::Provisioner.new({:logger => logger}).execute(action)
    }.to raise_error(Provisioner::ConfigurationError,
                     'VCloud credentials must be specified')
  end
end

describe 'Provisioner::Provisioner' do

  it_should_behave_like "validate credentials", 'create'
  it_should_behave_like "validate credentials", 'delete'

  it "should error out if action passed isn't present" do
    logger = mock(:debug => true, :error => true)
    expect {
      Provisioner::Provisioner.new({:logger => logger}).execute('disco')
    }.to raise_error(Provisioner::ConfigurationError,
                     'The action \'disco\' is not a valid action')
  end

  describe "delete" do
    pending "should delete vApp for the given vm name" do

    end
  end

end
