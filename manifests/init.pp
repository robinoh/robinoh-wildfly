# rji-wildfly
# The rji-wildfly Puppet module manages the installation, configuration, and
# application deployments for WildFly 8.
#
#   * Puppet Forge: http://forge.puppetlabs.com/robinoh/wildfly
#   * Project page: https://github.com/robinoh/robinoh-wildfly
#
#
# Class: wildfly
# This class is responsible for installing and configuring the WildFly Application
# Server. Application deployments can then be managed using `wildfly::deploy`.
#
class wildfly (
    $wildfly_user     = $wildfly::params::wildfly_user,
    $wildfly_group    = $wildfly::params::wildfly_group,
    $wildfly_dist     = $wildfly::params::wildfly_dist,
    $wildfly_home     = $wildfly::params::wildfly_home,
    $staging_dir    = $wildfly::params::staging_dir,
    $standalone_tpl = $wildfly::params::standalone_tpl
) inherits wildfly::params {
    # Ensure we're on a supported OS
    case $::operatingsystem {
        redhat, centos: { $supported = true }
        ubuntu:         { $supported = true }
        default:        { $supported = false }
    }

    if ($supported != true) {
        fail("Sorry, ${::operatingsystem} is not currently supported.")
    }

    # Check to see that a working Java install exists and is available in $PATH
    # Note that this module doesn't manage Java installations. If you need to
    # manage Java, try <https://github.com/puppetlabs/puppetlabs-java>
    exec { 'check-java':
      path    => $::path,
      command => 'java -version',
      unless  => 'java -version'
    }

    # Proceed with installation and config
    include wildfly::install, wildfly::config, wildfly::service
}
