# puppet_nginix

##Example use form Magento


    class { 'nginx': }
    nginx::vhost{ "domain.pl":
    vhost_aliases => 'www.domain.pl',
    tcp_port => '80',
    extra_config     => [
      'location @handler {rewrite / /index.php;}',
      'location ~ .php/ {rewrite ^(.*.php)/ $1 last;}',
      'location  /.                     {return 404;}',
      'location ^~ /app/                { return 404; }',
      'location ^~ /includes/           { return 404; }',
      'location ^~ /lib/                { return 404; }',
      'location ^~ /media/downloadable/ { return 404; }',
      'location ^~ /pkginfo/            { return 404; }',
      'location ^~ /report/config.xml   { return 404; }',
      'location ^~ /var/                { return 404; }',
      'location ^~ /.git/               { return 404; }',
      'location ^~ /shell/              { return 404; }',
      'location ^~ /downloader/         { return 404; }',
      'location /blog {index index.php;try_files $uri $uri/ /blog/index.php?$args;}'],
    https => true,
    ssl_certificate => "/etc/nginx/ssl/ssl.cert",
    
