class nginx::service inherits nginx {

  service { $nginx::params::service_name:
    ensure  => "running",
    enable  => "true",
    require => Package[$nginx::params::package_names],
  }

}