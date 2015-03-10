# Class: wildfly::service
# This class ensures the service is enabled and running.
#
class wildfly::service {

  include wildfly::config

  service { 'wildfly':
    ensure     => running,
    enable     => true,
    hasrestart => false,
    require    => File['/etc/wildfly/wildfly.conf'],
    subscribe  => File["${wildfly::wildfly_home}/standalone/configuration/standalone.xml"]
  }
}
