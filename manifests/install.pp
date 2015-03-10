# Class: wildfly::install
# This class is responsible for deploying the WildFly tarball and installing it
# and its service. It is broken into three main parts:
#
#   1. Create the user that WildFly will run as
#   2. Copy the WildFly tarball from the Puppet master and extract it on the
#      node.
#   3. Install the init script to /etc/init.d and add the service to chkconfig.
#
class wildfly::install {
  # Bring variables in-scope to improve readability
  $wildfly_user  = $wildfly::wildfly_user
  $wildfly_group = $wildfly::wildfly_group
  $wildfly_home  = $wildfly::wildfly_home
  $wildfly_dist  = $wildfly::wildfly_dist
  $staging_dir = $wildfly::staging_dir

  Exec {
    path => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
  }

  # Create the user that WildFly will run as
  user { $wildfly_user:
    ensure     => present,
    shell      => '/bin/bash',
    membership => 'minimum',
    managehome => true,
  }

  # As of Puppet 2.7, we can't manage parent dirs. Since we have no way of
  # knowing what directory the user chose for staging, or how deep it is,
  # we have this ugly hack.
  exec { 'create_staging_dir':
    command => "mkdir -p ${staging_dir}",
    unless  => "test -d ${staging_dir}"
  }

  file { $wildfly_home: ensure => directory }

  # Download the distribution tarball from the Puppet Master
  # and extract to $WILDFLY_HOME
  file { "${staging_dir}/${wildfly_dist}":
    ensure  => file,
    source  => "puppet:///modules/wildfly/${wildfly_dist}"
  }

  exec { 'extract':
    command => "tar zxf ${staging_dir}/${wildfly_dist} --strip-components=1 -C ${wildfly_home}",
    unless  => "test -d ${wildfly_home}/standalone",
    require => File["${staging_dir}/${wildfly_dist}", $wildfly_home]
  }

  exec { 'set_permissions':
    command => "chown -R ${wildfly_user}:${wildfly_group} ${wildfly_home}",
    unless  => "test -d ${wildfly_home}/standalone",
    require => Exec['extract']
  }

  # Install the init scripts and the service to chkconfig / rc.d
  #
  # Because variable scope is inconsistent between Puppet 2.7 and 3.x,
  # we need to redefine the WILDFLY_HOME variable within this scope.
  # For more info, see http://docs.puppetlabs.com/guides/templating.html
  $this_wildfly_home        = $wildfly_home
  $initscript_template    = $wildfly::params::initscript_template
  $initscript_install_cmd = $wildfly::params::initscript_install_cmd

  file { '/etc/init.d/wildfly':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("wildfly/${initscript_template}")
  }

  exec { 'install_service':
    command => $initscript_install_cmd,
    require => File['/etc/init.d/wildfly'],
    unless  => 'test -f /etc/init.d/wildfly'
  }
}
