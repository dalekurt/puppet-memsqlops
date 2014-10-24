# == Class: memsqlops
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
# [*memsqlops_src_dir*]
#   Location to unpack source code before building and installing it.
#   Default: /opt/memsqlops-src
#
# [*memsqlops_bin_dir*]
#   Location to install memsqlops binaries.
#   Default: /opt/memsqlops
#
# === Examples
#
# include memsqlops
#
# class { 'memsqlops':
#   version        => '3.1.2',
#   license        => 'LICENSE_KEY'
#   memsqlops_src_dir => '/path/to/memsqlops-src',
#   memsqlops_bin_dir => '/path/to/memsqlops',
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
class memsqlops (
  $version                = $memsqlops::params::version,
  $license                = $memsqlops::params::license,
  $memsqlops_src_dir     = $memsqlops::params::memsqlops_src_dir,
  $memsqlops_bin_dir     = $memsqlops::params::memsqlops_bin_dir,
  $memsqlops_dbhost      = $memsqlops::params::memsqlops_dbhost,
  $memsqlops_dbport      = $memsqlops::params::memsqlops_dbport,
  $memsqlops_dbuser      = $memsqlops::params::memsqlops_dbuser,
  $memsqlops_dbpass      = $memsqlops::params::memsqlops_dbpass,
  $memsqlops_dbname      = $memsqlops::params::memsqlops_dbname,
  $memsqlops_bindaddress = $memsqlops::params::memsqlops_bindaddress,
  $memsqlops_port        = $memsqlops::params::memsqlops_port

) inherits memsqlops::params {

  include wget
  include gcc

  $memsqlops_pkg_name = 'memsqlops-${version}.tar.gz'
  $memsqlops_pkg      = '${memsqlops_src_dir}/${memsqlops_pkg_name}'

#  memsqlops::instance { 'memsqlops-default':
#    memsqlops_bindaddress => $memsqlops_bindaddress,
#    memsqlops_port        => $memsqlops_port,
#    memsqlops_dbhost      => $memsqlops_dbhost,
#    memsqlops_dbport      => $memsqlops_dbport,
#    memsqlops_dbuser      => $memsqlops_dbuser,
#    memsqlops_dbpass      => $memsqlops_dbpass,
#    memsqlops_dbname      => $memsqlops_dbname,
#  }

  # download memsql from the memsql.com website
  exec { 'get-memsqlops-pkg':
    command => "wget http://download.memsql.com/${license}/${memsqlops_pkg_name}",
    cwd     => $memsqlops_src_dir,
    path    => "/usr/bin",
    unless  => "test -f ${memsqlops_pkg}",
    require => File[$memsqlops_src_dir],
  }

  # extract memsqlops to the memsqlops_bin_dir
  exec { 'unpack-memsqlops':
    command => "tar --strip-components 1 -xzf ${memsqlops_pkg}",
    cwd     => $memsqlops_bin_dir,
    path    => '/bin:/usr/bin',
    unless  => "test -f ${memsqlops_src_dir}/Makefile",
    subscribe => [ Exec['get-memsqlops-pkg'], File[ $memsqlops_bin_dir] ],
    refreshonly => true,
  }

  # create the memsql init script
  file { "memsqlops-init":
    ensure  => present,
    path    => "/etc/init.d/memsqlops",
    mode    => '0755',
    content => template('memsql/memsqlops.init.erb'),
    notify  => [ Service["memsqlops"] ],
  }

  # start the memsql daemon using the init script
  service { "memsqlops":
    ensure    => running,
    name      => "memsqlops",
    enable    => true,
    require   => [ File['memsqlops-init'], Exec['get-memsqlops-pkg'], Exec['unpack-memsqlops'] ],
  }
}
