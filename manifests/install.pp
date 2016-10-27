class nginx::install inherits nginx {

  #notify { $nginx::ensure: }
  package { $nginx::params::package_names:
    ensure => $nginx::ensure,
    #notify  => Service["${nginx::params::service_name}"], startuje dopiero z vhostem
  }

  file { "${nginx::params::conf_dir}/default.conf": ensure => absent }
  file { "${nginx::params::conf_dir}/virtual.conf": ensure => absent }
  file { "${nginx::params::conf_dir}/ssl.conf": ensure => absent }
  file { "${nginx::params::conf_dir}/default": ensure => absent }


  file { "/etc/nginx/nginx.conf":
    ensure => present,
    content => template ("${module_name}/nginx.conf.erb"),
    require => Package['nginx']
  }
}