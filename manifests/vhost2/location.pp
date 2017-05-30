define nginx::vhost2::location (
  $location = $name,
  $vhost,
  $deny       = undef,
  $params = {},
  $order = "100",
  $authentication = false,
  $description  = undef,
  $authentication_file = Nginx::Vhost2[$vhost]["authentication_file"]
)
{
  if($location != "")
  {
    concat::fragment { "${name}":
      target  => "${vhost}",
      content => template("${module_name}/vhost2/location.erb"),
      order   => $order,
    }
  }
}