class nginx::params {

  $ensure           = 'present' #'purged'/'present'
  $vhost_aliases    = ''
  $tcp_port         = '80'
  $ip_addr          = '*'
  $document_root    = '/srv/www'
  $document_index   = 'index.php'
  $fastcgi_param    = []
  $extra_config     = [ 'location  /. {return 404;}',
                        'location @handler {rewrite / /index.php;}',
                        'location ~ .php/ {rewrite ^(.*.php)/ $1 last;}']
  $extra_root_location = ['try_files $uri $uri/ @handler;']
  $php_proxy        = true
  $https            = false
  $log_dir          = '/var/log/nginx'
  $timeout          = 30
  $upload_size      = '8M'
  $port_in_redirect = "off"

  case $::osfamily {
    'Debian': {
      $package_names  = [ 'nginx' ]

      $service_name   = 'nginx'
      $conf_dir       = '/etc/nginx/sites-enabled'
      $username    = 'www-data'
      $pid     = '/run/nginx.pid'
    }
    'RedHat': {
      $package_names  = [ 'nginx' ]

      $service_name   = 'nginx'
      $conf_dir       = '/etc/nginx/conf.d'
      $username       = 'nginx'
      $pid            = '/var/run/nginx.pid'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}