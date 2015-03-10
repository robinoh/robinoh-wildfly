# Definition: wildfly::deploy
# Deploys a EAR/WAR application archive to a WildFly.
#
define wildfly::deploy(
  $pkg         = $title,
  $is_deployed = true,
  $hot_deploy  = true
) {
  include wildfly
  $deploy_dir = "${wildfly::wildfly_home}/standalone/deployments"

  case $is_deployed {
    true:  { $ensure = 'present' }
    false:   { $ensure = 'absent' }
    default: { $ensure = 'present' }
  }

  # Hot deploy allows for packages to be deployed and undeployed on a WildFly
  # system without restarting the application server. In certain environments,
  # this can lead to memory leaks, but otherwise its use is acceptable. The
  # default here is to use hot deploy.
  File {
    owner   => $wildfly::wildfly_user,
    group   => $wildfly::wildfly_group,
    mode    => '0664',
    require => Class['wildfly::install', 'wildfly::config']
  }

  if ($hot_deploy == true) {
    file { "${deploy_dir}/${pkg}":
      ensure => $ensure,
      source => "puppet:///modules/wildfly/${pkg}"
    }
  }
  else {
    file { "${deploy_dir}/${pkg}":
      ensure => $ensure,
      source => "puppet:///modules/wildfly/${pkg}",
      notify => Service['wildfly']
    }
  }
}
