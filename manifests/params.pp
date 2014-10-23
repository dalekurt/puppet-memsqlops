# == Class: memsql-ops::params
#
# memsql-ops params.
#
# === Parameters
#
# === Authors
#
# Dale-Kurt Murray
#
# === Copyright
#
# Copyright 2014 Dale-Kurt Murray, unless otherwise noted.
#
class memsql-ops::params {

  $version               = '3.1.2'
  $license               = '6f1baebd40ea4b14bea2c8bdf2849552'
  $memsql-ops_src_dir    = '/opt/memsql-ops-src'
  $memsql-ops_bin_dir    = '/opt/memsql-ops'
  $memsql-ops_dbhost     = 'localhost'
  $memsql-ops_dbport     = '3306'
  $memsql-ops_dbuser     = 'root'
  $memsql-ops_dbpass     = ''
  $memsql-ops_dbname     = 'dashboard'
  $memsql-ops_host       = '0.0.0.0'
  $memsql-ops_port       = '9000'
}
