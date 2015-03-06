# cd /vagrant
# sudo puppet apply --modulepath /etc/puppet/modules:/vagrant/puppet puppet/server.pp

$runner = {
  name  => 'search',
  group => 'users',
  home  => '/home/search'
}

$runners_path = "${::runner[home]}/.rbenv/shims:${::runner[home]}/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"

$app_dir = "/${::runner[home]}/webapp"

$db = {
  name            => 'sitesearch',
  user            => 'search',
  password        => template('malmo/pw_generator.erb'),
  root_password   => template('malmo/pw_generator.erb'),
  daily_backup    => "true",
  backup_password => template('malmo/pw_generator.erb'),
  backup_time     => ['3', '45'],
  backup_dir      => "/home/${::runner['name']}/backups",
}

$elasticsearch = {
  version => '1.4', # major.minor
  size    => '1024',
}
$memcached_size = '512'
$ruby_version    = '2.2.1'

include malmo::system
include malmo::rbenv
include malmo::mysql
include malmo::elasticsearch
include malmo::memcached
include malmo::nginx
include malmo::bundle::install
include malmo::bundle::db_migrate
include malmo::post_install
