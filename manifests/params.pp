# Class wildfly::params
# Parameters used throughout the module.
#
class wildfly::params {
  $wildfly_user     = 'wildfly'
  $wildfly_group    = 'wildfly'
  $wildfly_dist     = 'wildfly-8.2.0.Final.tar.gz'
  $wildfly_home     = '/usr/share/wildfly'
  $staging_dir    = '/tmp/puppet-staging/wildfly'
  $standalone_tpl = 'wildfly/standalone.xml.erb'

  # Init script template and install commands based on OS
  case $::operatingsystem {
    redhat, centos: {
      $initscript_template    = 'wildfly-initscript-el.sh.erb'
      $initscript_install_cmd = 'chkconfig --add wildfly'
    }
    ubuntu: {
      $initscript_template    = 'wildfly-initscript-ubuntu.sh.erb'
      $initscript_install_cmd = 'update-rc.d wildfly defaults'
    }
    default: {
      # Note that we should never make it here... if the OS is unsupported,
      # it should have failed in `init.pp`.
      fail("Unsupported operating system ${::operatingsystem}")
    }
  }
}
