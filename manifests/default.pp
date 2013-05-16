exec { 'apt-get update' :
    command => 'apt-get update',
    path    => '/usr/bin/',
    timeout => 60,
    tries   => 3
}

class { 'apt' :
    always_apt_update => true
}

package { ['python-software-properties'] :
    ensure  => 'installed',
    require => Exec['apt-get update'],
}

file { '/home/vagrant/.bash_aliases' :
    source => 'puppet:///modules/puphpet/dot/.bash_aliases',
    ensure => 'present',
}

package { ['build-essential', 'vim', 'curl', 'make', 'yum', 'git', 'openssl', 'subversion'] :
    ensure  => 'installed',
    require => Exec['apt-get update'],
}

class { 'apache' : }

apache::dotconf { 'custom' :
    content => 'EnableSendfile Off',
}

    apache::module { 'rewrite' : }
    apache::module { 'proxy' : }

    apache::vhost { 'test-local' :
        server_name   => 'test-local',
        serveraliases => [],
        docroot       => '/vagrant/www/test',
        port          => '80',
        env_variables => ['APP_ENV dev'],
        priority      => '1'
    }


class { 'php' :
    service => 'apache',
    require => Package['apache'],
}

    php::module { 'php5-curl' : }
    php::module { 'php5-mcrypt' : }
    php::module { 'php5-memcache' : }
    php::module { 'php5-memcached' : }
    php::module { 'php5-odbc' : }
    php::module { 'php-apc' : }
    php::module { 'php-openid' : }

class { 'php::devel' :
    require => Class['php'],
}

    class { 'php::pear' :
        require => Class['php'],
    }

            php::pear::module { 'PHP_CodeSniffer' :
            use_package => false
        }
    
    
            class { 'xdebug' : }

        xdebug::config { 'cgi' : }
        xdebug::config { 'cli' : }
    
php::ini { 'default' :
    value    => [
        'date.timezone = America/Chicago',
        'display_errors = On',
        'error_reporting = -1'
    ],
    target   => 'error_reporting.ini'
}

