# This script it to be uploaded to s3 from where it is pulled down
# It is only here for purposes of change control. Please upload to S3 if you are commiting a change to this file
. /etc/lsb-release

apt-get update
# apt-get -y dist-upgrade

if [ "$DISTRIB_CODENAME" = "lucid" ]; then

  RUBY_PACKAGE="https://some.path.to.ruby"
  cd $(mktemp -d /tmp/install_ruby.XXXXXXXXXX) && \
    wget -q -O ruby.deb $RUBY_PACKAGE && \
    dpkg -i ruby.deb
else
  sed -i '/^deb cdrom/d' /etc/apt/sources.list
  apt-get -y install ruby1.9.3
  export PATH=$PATH:/usr/local/bin
fi

echo "${PUPPET_MASTER_IP} puppet" >> /etc/hosts

gem install -v $PUPPET_VERSION puppet --no-rdoc --no-ri

rm -rf /etc/puppet
mkdir -p /etc/puppet
cat <<EOF >/etc/puppet/puppet.conf
[main]
pluginsync = true

[agent]
report = false
configtimeout = 600
EOF

puppet agent --pluginsync --configtimeout 600 -t --waitforcert 60
