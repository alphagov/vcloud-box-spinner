# This script it to be uploaded to s3 from where it is pulled down
# It is only here for purposes of change control. Please upload to S3 if you are commiting a change to this file
RUBYGEMS_URL="http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz"

apt-get update
# apt-get -y dist-upgrade

sed -i '/^deb cdrom/d' /etc/apt/sources.list
apt-get -y install git ruby1.9.3
export PATH=$PATH:/usr/local/bin

update-alternatives --set ruby /usr/bin/ruby1.9.1

gem install -v $PUPPET_VERSION puppet --no-rdoc --no-ri
gem install bundler -v 1.1.4 --no-ri --no-rdoc

sed -i /etc/hosts -e 's/localhost/localhost puppet/'

useradd puppet
useradd deploy -m -s /bin/bash

mkdir -p /etc/puppet /usr/share/puppet/production/releases /usr/share/puppet/production/shared /usr/share/puppet/production/shared/cached-copy
cd /usr/share/puppet/production
chown -R deploy: /usr/share/puppet/*
cd -
