# Class: wildfly::config
# Configures the WildFly, some JVM runtime parameters, and add'l modules.
#
class wildfly::config {

  file { "${wildfly::wildfly_home}/standalone/configuration/standalone.xml":
    ensure  => present,
    owner   => 'root',
    group   => $wildfly::wildfly_group,
    mode    => '0644',
    content => template($wildfly::standalone_tpl),
    require => Class['wildfly::install']
  }

  file { '/etc/wildfly': ensure => directory }

  file { '/etc/wildfly/wildfly.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('wildfly/wildfly-service.conf.erb'),
    require => File['/etc/wildfly', '/etc/init.d/wildfly']
  }

  # Add additional JBoss modules (datastore drivers, etc) below.

}
