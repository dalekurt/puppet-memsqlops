# == Class: memsql-ops
#
# Install memSQL Ops.
#
# === Parameters
#
# [*version*]
#   Version to install.
#
# [*license*]
#   License provided by memsql.
#
# [*memsql-ops_src_dir*]
#   Location to unpack source code before building and installing it.
#   Default: /opt/memsql-ops-src
#
# [*memsql-ops_bin_dir*]
#   Location to install memsql-ops binaries.
#   Default: /opt/memsql-ops
#
# === Examples
#
# include memsql-ops
#
# class { 'memsql-ops':
#   version        => '3.1.2',
#   license        => 'LICENSE_KEY'
#   memsql-ops_src_dir => '/path/to/memsql-ops-src',
#   memsql-ops_bin_dir => '/path/to/memsql-ops',
# }
#
# === Authors
#
# Dale-Kurt Murray
#
# === Copyright
#
# Copyright 2014 Dale-Kurt Murray, unless otherwise noted.
#

# Install memSQL from tarball file
class memsql-ops (
  $version                = $memsql-ops::params::version,
  $license                = $memsql-ops::params::license,
  $memsql-ops_src_dir     = $memsql-ops::params::memsql-ops_src_dir,
  $memsql-ops_bin_dir     = $memsql-ops::params::memsql-ops_bin_dir,
  $memsql-ops_dbhost      = $memsql-ops::params::memsql-ops_dbhost,
  $memsql-ops_dbport      = $memsql-ops::params::memsql-ops_dbport,
  $memsql-ops_dbuser      = $memsql-ops::params::memsql-ops_dbuser,
  $memsql-ops_dbpass      = $memsql-ops::params::memsql-ops_dbpass,
  $memsql-ops_dbname      = $memsql-ops::params::memsql-ops_dbname,
  $memsql-ops_bindaddress = $memsql-ops::params::memsql-ops_bindaddress,
  $memsql-ops_port        = $memsql-ops::params::memsql-ops_port

) inherits memsql-ops::params {

  include wget
  include gcc

  $memsql-ops_pkg_name = 'memsql-ops-${version}.tar.gz'
  $memsql-ops_pkg      = '${memsql-ops_src_dir}/${memsql-ops_pkg_name}'

  memsql-ops::instance { 'memsql-ops-default':
    memsql-ops_bindaddress => $memsql-ops_bindaddress,
    memsql-ops_port        => $memsql-ops_port,
    memsql-ops_dbhost      => $memsql-ops_dbhost,
    memsql-ops_dbport      => $memsql-ops_dbport,
    memsql-ops_dbuser      => $memsql-ops_dbuser,
    memsql-ops_dbpass      => $memsql-ops_dbpass,
    memsql-ops_dbname      => $memsql-ops_dbname,

  }

  # download memsql from the memsql.com website
  exec { 'get-memsql-ops-pkg':
    command => "wget http://download.memsql.com/${license}/${memsql-ops_pkg_name}",
    cwd     => $memsql-ops_src_dir,
    path    => "/usr/bin",
    unless  => "test -f ${memsql-ops_pkg}",
    require => File[$memsql-ops_src_dir],
  }

  # extract memsql-ops to the memsql-ops_bin_dir
  exec { 'unpack-memsql-ops':
    command => "tar --strip-components 1 -xzf ${memsql-ops_pkg}",
    cwd     => $memsql-ops_bin_dir,
    path    => '/bin:/usr/bin',
    unless  => "test -f ${memsql-ops_src_dir}/Makefile",
    subscribe => [ Exec['get-memsql-ops-pkg'], File[ $memsql-ops_bin_dir] ],
    refreshonly => true,
  }

  # create the memsql init script
  file { "memsql-ops-init":
    ensure  => present,
    path    => "/etc/init.d/memsql-ops",
    mode    => '0755',
    content => template('memsql/memsql-ops.init.erb'),
    notify  => [ Service["memsql-ops"] ],
  }

  # start the memsql daemon using the init script
  service { "memsql-ops":
    ensure    => running,
    name      => "memsql-ops",
    enable    => true,
    require   => [ File['memsql-ops-init'], Exec['get-memsql-ops-pkg'], Exec['unpack-memsql-ops'] ],
  }
}
