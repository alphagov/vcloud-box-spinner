if [ $1 = "postcustomization" ]; then
  set -e
  exec >/var/log/userdata.log 2>&1
  export DEBIAN_FRONTEND=noninteractive

  PUPPET_VERSION="3.2.2"
  PUPPET_MASTER_IP=<%= options[:master_ip] %>

  echo "LC_ALL=en_GB.UTF-8" > /etc/environment
  <% if options[:class] %>
    echo "FACTER_govuk_class=<%= options[:class] %>" >> /etc/environment
    echo "FACTER_govuk_platform=<%= options[:platform] %>" >> /etc/environment
    echo "FACTER_govuk_provider=sky" >> /etc/environment
    export FACTER_govuk_class=<%= options[:class] %>
    export FACTER_govuk_platform=<%= options[:platform] %>
    export FACTER_govuk_provider=sky
  <% end %>

  echo "nameserver 8.8.8.8" >/etc/resolv.conf
  echo "nameserver 8.8.4.4" >>/etc/resolv.conf
  apt-get install openssh-server
fi
