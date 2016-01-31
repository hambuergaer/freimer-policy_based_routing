#
# TBD: Documentation
class policy_based_routing (
  $nics = [ 'eth0' ] )
{

exec {'notifier-dummy':
    command     => '/bin/true',
    refreshonly => true,
}

# Create etc/sysconfig/network-scripts/rule-${nic} for every interface
  define iprule {
    $nic = $name
    $address = inline_template("<%= scope.lookupvar('::ipaddress_${nic}') -%>")

    file { "/etc/sysconfig/network-scripts/rule-${nic}":
      ensure  => file,
      content => template('policy_based_routing/rule.erb'),
      notify  => Exec['notifier-dummy'],
    }
  }
  iprule { $nics:; }

  # Create etc/sysconfig/network-scripts/route-${nic} for every interface
  define iproute {
    $nic = $name
    $gateway = inline_template("<%= scope.lookupvar('::gateway_${nic}') -%>")
    $net = inline_template("<%= scope.lookupvar('::network_${nic}') -%>")
    $mask = inline_template("<%= scope.lookupvar('::netmask_${nic}') -%>")

    file { "/etc/sysconfig/network-scripts/route-${nic}":
      ensure  => file,
      content => template('policy_based_routing/route.erb'),
      notify  => Exec['notifier-dummy'],
    }
  }
  iproute { $nics:; }


  case $::operatingsystemmajrelease  {
    6:
    {
      # Ensure policy-based routing service is enabled and running
      service { 'network':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => Exec['notifier-dummy'],
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  case $::operatingsystemmajrelease  {
    7:
    {
      # Install required packages
      package {'NetworkManager-config-routing-rules':
        ensure => present,
      }
  
    # Ensure policy-based routing service is enabled and running
      service { 'NetworkManager':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => Exec['notifier-dummy'],
      }
  
      service { 'NetworkManager-dispatcher.service':
        ensure  => running,
        enable  => true,
        require => Package['NetworkManager-config-routing-rules'],
      }
  
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
