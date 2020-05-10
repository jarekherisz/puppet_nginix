define nginx::vhost2 (

  $ensure                                 = $nginx::params::ensure,
  $vhost                                  = $name,
  $set_variables                          = {},
  $vhost_aliases                          = $nginx::params::vhost_aliases,
  $tcp_port                               = $nginx::params::tcp_port,
  $ip_addr                                = $nginx::params::ip_addr,
  $log_dir                                = $nginx::params::log_dir,
  $conf_dir                               = $nginx::params::conf_dir,
  Variant[String, Boolean] $path          = "${nginx::params::document_root}/${name}",
  Variant[String, Boolean] $document_root = "${path}",
  $chmod_path                             = "2770",
  $document_index                         = $nginx::params::document_index,
  $username                               = $nginx::params::username,
  $usergroup                              = $username,
  $file_username                          = $username,
  $file_usergroup                         = $usergroup,
  $php_proxy                              = $nginx::params::php_proxy,
  $debug                                  = false,
  $php_pool                               = "unix:/var/run/php5-fpm-${name}.sock",
  $set_real_ip_from                       = "127.0.0.1",
  $real_ip_header                         = "X-Forwarded-For",
  $client_max_body_size                   = $nginx::params::upload_size,
  $port_in_redirect                       = $nginx::params::port_in_redirect,
  $fastcgi_read_timeout                   = $nginx::params::timeout,
  $https                                  = $nginx::params::https,
  $ssl_certificate                        = "somecert.crt",
  $ssl_certificate_key                    = "somecert.key",
  $authentication_file                    = "${path}/.authentication",
  $authentication                         = [],
  $header_params                          = [],
  $filters                                = true,
  $filters_string                         = "",
  Variant[String, Boolean] $upstream      = false,
  $upstream_params                        = [],

  $locations                              = {},
  $locations_d                            = {
    "root"     => {
      "location"    => "/",
      "vhost"       => "${name}",
      "order"       => "011",
      "description" => "Main site location",
      "params"      => {
        "index"     => "${document_index}",
        'try_files' => '$uri $uri/ @handler'
      }
    },
    'handler'  => {
      'location' => '@handler',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'rewrite /' => "/${$document_index}" }
    },
    "hidden"   => {
      "location"    => "~ /\.",
      "vhost"       => "${name}",
      "order"       => "009",
      "description" => "Skip hidden file like .git, .htpasswd, etc.",
      "params"      => {
        "return" => "404"
      }
    },
    'favicon'  => {
      'location'    => '= /favicon.ico',
      "vhost"       => "${name}",
      "order"       => "010",
      "description" => [
        "Wylacza logowanie i serwuje plik gdy jest dostepny.",
        "Gdy nie istnieje to serwuje pusty plik (kod 204) dzieki czemu nie przeszkadzaja nam 404-ki ",
      ],
      "params"      => {
        'try_files'     => '/favicon.ico =204',
        'access_log'    => 'off',
        'log_not_found' => 'off'
      }
    },
    'robots'   => {
      'location'    => '= /robots.txt',
      "vhost"       => "${name}",
      "order"       => "010",
      "description" => [
        "Wylacza logowanie i serwuje plik gdy jest dostepny.",
        "Gdy nie istnieje to serwuje pusty plik (kod 204) dzieki czemu nie przeszkadzaja nam 404-ki ",
      ],
      "params"      => {
        'try_files'     => '/robots.txt =204',
        'access_log'    => 'off',
        'log_not_found' => 'off'
      }
    },
    'main_php' => {
      'location' => '~ \.php$',
      'vhost'    => "${name}",
      'order'    => "800",
      'params'   => {
        'try_files'                     => '$uri =404',
        "add_header X-Server"           => '$hostname',
        'include'                       => 'fastcgi_params',
        'fastcgi_pass'                  => $php_pool,
        'fastcgi_index'                 => $document_index,
        'fastcgi_param SCRIPT_FILENAME' => '$document_root$fastcgi_script_name',
        'fastcgi_param SCRIPT_NAME'     => '$fastcgi_script_name',
        'fastcgi_read_timeout'          => $fastcgi_read_timeout
      }
    }
  }
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

    if ($path != false) and (!defined(Exec[$path])) and (!defined(File[$path])) {
      exec { $path:
        path    => ['/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin'],
        command => "mkdir -p $path ",
        unless  => "test -d $path ",
      } ->


      file { $path:
        ensure  => "directory",
        owner   => $file_username,
        group   => $file_usergroup,
        mode    => $chmod_path,
        require => Exec[$path ],
      }

    }

    concat { "${name}":
      path    => "${conf_dir}/${name}.conf",
      ensure  => $ensure,
      notify  => Service["${nginx::params::service_name}"],
      require => Package['nginx']
    }

    concat::fragment { "${name}_header":
      target  => "${name}",
      content => template("${module_name}/vhost2/header.erb"),
      order   => '000',
    }


    concat::fragment { "${name}_footer":
      target  => "${name}",
      content => template("${module_name}/vhost2/footer.erb"),
      order   => '999',
    }

    ##Łączy dwie tabele
    $merge_locations = deep_merge($locations_d, $locations)

    ##Dodaje prefix aby kazty host mial unikalne location-y
    $prefix_locations = prefix($merge_locations, "${name}::")

    create_resources(nginx::vhost2::location, $prefix_locations)

    if (empty($authentication) == false )
    {
      if(!defined(File[$authentication_file]))
      {
        file { $authentication_file:
          ensure  => present,
          content => template("${module_name}/authentication.erb"),
          require => File[$path]
        }
      }
    }
  }

}