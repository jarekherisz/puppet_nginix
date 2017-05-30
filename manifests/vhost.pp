define nginx::vhost (

  $ensure                       = $nginx::params::ensure,
  $vhost                        = $name,
  $vhost_aliases                = $nginx::params::vhost_aliases,
  $tcp_port                     = $nginx::params::tcp_port,
  $ip_addr                      = $nginx::params::ip_addr,
  $document_root                = "${nginx::params::document_root}/${name}",
  $document_index               = $nginx::params::document_index,
  $fastcgi_param                = $nginx::params::fastcgi_param,
  $extra_config                 = $nginx::params::extra_config,
  $extra_root_location          = $nginx::params::extra_root_location,
  $php_proxy                    = $nginx::params::php_proxy,
  $log_dir                      = $nginx::params::log_dir,
  $conf_dir                     = $nginx::params::conf_dir,
  $php_pool                     = "unix:/var/run/php5-fpm-${name}.sock",
  $username                     = $nginx::params::username,
  $usergroup                     = $username,
  $fastcgi_read_timeout         = $nginx::params::timeout,
  $client_max_body_size         = $nginx::params::upload_size,
  $authentication               = [],
  $port_in_redirect             = $nginx::params::port_in_redirect,
  $https                        = $nginx::params::https,
  $http_to_https               = false,
  $https_tcp_port               = '443',
  $ssl_certificate              = "somecert.crt",
  $ssl_certificate_key          = "somecert.key",

) {

  if ($ensure == 'disable' or $ensure == 'disabled' or $ensure == 'absent') {
    file { "${conf_dir}/${name}.conf":
      ensure => absent,
    }
  } else {

    if $log_dir != undef and !defined(File[$log_dir]) {
      file { $log_dir:
        ensure => "directory",
      #owner  => $username,
      #group  => $username,
        mode   => "775",
      }
    }

    if !defined(Exec[$document_root]) {
      exec { $document_root:
        path    => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
        command => "mkdir -p ${document_root}",
        unless  => "test -d ${document_root}",
      } ->
        if !defined(File[$document_root]) {
          file { "${document_root}":
            ensure  => "directory",
            owner   => $username,
            group   => $usergroup,
            mode    => "2775",
            require => Exec[$document_root],
          }
        }
    }

    file { "${conf_dir}/${name}.conf":
      ensure => present,
      content => template ("${module_name}/vhost.erb"),
      notify  => Service["${nginx::params::service_name}"],
      require => Package['nginx']
    }

    if ($https == true )
    {
      file { "${conf_dir}/ssl.${name}.conf":
        ensure => present,
        content => template ("${module_name}/vhostssl.erb"),
        notify  => Service["${nginx::params::service_name}"],
        require => Package['nginx']
      }
    }


    file { "${document_root}/.authentication":
      ensure => present,
      content => template ("${module_name}/authentication.erb"),
      require => File["${document_root}"]
    }

  }

}