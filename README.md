# NGINX module for Puppet


### Install and bootstrap an NGINX instance

```puppet
class { 'nginx': }
```


### A virtual host
By default vhost is configured:
- to works with fpm-php, it connect to "unix:/var/run/php5-fpm-${name}.sock",
- document_root is "/srv/www/${name}",
- tcp_port is '80'
- listen ip_addr is'*'
- document_index is 'index.php'
- php_proxy is true
- https is false
- log_dir is '/var/log/nginx'
```puppet
nginx::vhost2  { "domain.com": }
```

### A virtual host with alias name
```puppet
nginx::vhost2  { "domain.com": 
    vhost_aliases => 'www.domain.com www2.domain.com',
}
```

### Locations
Module split all config for the location. Each location has parameters:
- name: name of resource
- location: location in nginix, for example '~ \.php$'
- deny set "all" if you want reject locations
- order: defines the order in the config file 
- authentication set true if you want login to location
- authentication_file patch to file witch user and pass authentication_file
- description add desctiption to config file
- params, any location parameters

For example authentication for root location
```puppet
nginx::vhost2  { "domain.com": 
    authentication => { 'user'=>'$apr1$epIUboiA$QggYxiTUOeGWYweiBVyqL.'}, #test:test
    locations => {
        'root' => {
            'authentication' => true,
        }
    }
}
```

###SSL configuration
```puppet
nginx::vhost2  { "domain.com": 
    tcp_port => '443',
    https => true,
    ssl_certificate => "somecert.crt",
    ssl_certificate_key => "somecert.key",
}
```



