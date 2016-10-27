
class nginx ( $ensure = $nginx::paraps::ensure ) inherits nginx::params {
  anchor { 'nginx::begin': }
  class { '::nginx::install': }
  class { '::nginx::service': }
  anchor { 'nginx::end': }
}

