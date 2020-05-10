
class nginx (
  $ensure = $nginx::params::ensure,
  $worker_connections = $nginx::params::worker_connections,
  $keepalive_timeout  = $nginx::params::keepalive_timeout,
) inherits nginx::params {
  anchor { 'nginx::begin': }
  class { '::nginx::install':
    worker_connections => $worker_connections,
    keepalive_timeout => $keepalive_timeout
  }
  class { '::nginx::service': }
  anchor { 'nginx::end': }
}

