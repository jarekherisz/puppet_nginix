class nginx::pagespeed inherits nginx {

  file { "/etc/nginx/conf.d/pagespeed.conf":
    ensure => present,
    content => template ("${module_name}/pagespeed.conf.erb"),
    require => Package['nginx'],
    notify  => Service["${nginx::params::service_name}"],
  }
}