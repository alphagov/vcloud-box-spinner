specdir=File.dirname(__FILE__)
$:.unshift File.join(specdir, '../lib')
$:.unshift File.join(specdir, '..')

require 'rspec'
require 'webmock/rspec'

Rspec.configure do |config|
  config.backtrace_clean_patterns = [
  ]
end

# Redirects stderr and stdout to /dev/null.
def silence_output
  @orig_stderr = $stderr
  @orig_stdout = $stdout

  # redirect stderr and stdout to /dev/null
  $stderr = File.new('/dev/null', 'w')
  $stdout = File.new('/dev/null', 'w')
end

# Replace stdout and stderr so anything else is output correctly.
def enable_output
  $stderr = @orig_stderr
  $stdout = @orig_stdout
  @orig_stderr = nil
  @orig_stdout = nil
end
