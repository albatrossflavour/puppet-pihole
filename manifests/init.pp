# @summary Install, configure, and manage your pihole
#
# Blocks ads using Pi-hole DNS filtering
#
# @param installer_url
#   URL to download the Pi-hole installer from
# @param installer_filename
#   Local filename for the downloaded installer script
# @param installer_path
#   Directory path where the installer script will be downloaded
# @param interface
#   Network interface Pi-hole should bind to (e.g., 'eth0')
# @param dns_servers
#   Array of upstream DNS servers to use
# @param dns_domain
#   Local domain name for Pi-hole
# @param dns_hosts
#   Array of custom DNS host entries in format ["ip hostname", ...]
# @param listening_mode
#   DNS listening mode (LOCAL, SINGLE, BIND, ALL, NONE)
# @param webserver_enabled
#   Enable the Pi-hole web interface
# @param webserver_port
#   Port configuration for web interface
# @param api_password_hash
#   Hashed password for API access (leave empty to disable authentication)
# @param query_logging
#   Enable DNS query logging
# @param privacy_level
#   Privacy level (0-4, where 0 is least private)
# @param dhcp_enabled
#   Enable the built-in DHCP server
# @param cache_size
#   DNS cache size
# @param blocking_enabled
#   Enable DNS blocking functionality
# @param dns_advanced
#   Hash of advanced DNS configuration options
# @param webserver_advanced
#   Hash of advanced webserver configuration options
# @param dhcp_config
#   Hash of DHCP server configuration options
# @param ntp_config
#   Hash of NTP server configuration options
# @param database_config
#   Hash of database configuration options
# @param misc_config
#   Hash of miscellaneous configuration options
# @param debug_config
#   Hash of debug configuration options
# @param user
#   User account for Pi-hole processes
# @param group
#   Group for Pi-hole processes
#
# @example Basic usage
#   include pihole
#
# @example Advanced configuration
#   class { 'pihole':
#     interface      => 'eth0',
#     dns_servers    => ['1.1.1.1', '8.8.8.8'],
#     dns_hosts      => [
#       '192.168.1.10 server.local',
#       '192.168.1.20 nas.local',
#     ],
#     dns_advanced   => {
#       'CNAMEdeepInspect' => false,
#       'blockESNI'        => false,
#     },
#   }
class pihole (
  String $installer_url = 'https://install.pi-hole.net',
  String $installer_filename = 'basic-install.sh',
  Stdlib::Absolutepath $installer_path = '/opt',
  Optional[String] $interface = undef,
  Array[String] $dns_servers = ['8.8.8.8', '8.8.4.4'],
  String $dns_domain = 'lan',
  Array[String] $dns_hosts = [],
  Enum['LOCAL', 'SINGLE', 'BIND', 'ALL', 'NONE'] $listening_mode = 'LOCAL',
  Boolean $webserver_enabled = true,
  String $webserver_port = '80o,443os,[::]:80o,[::]:443os',
  Optional[String] $api_password_hash = undef,
  Boolean $query_logging = true,
  Integer[0,4] $privacy_level = 0,
  Boolean $dhcp_enabled = false,
  Integer[1000,50000] $cache_size = 10000,
  Boolean $blocking_enabled = true,
  Hash $dns_advanced = {},
  Hash $webserver_advanced = {},
  Hash $dhcp_config = {},
  Hash $ntp_config = {},
  Hash $database_config = {},
  Hash $misc_config = {},
  Hash $debug_config = {},
  String $user = 'pihole',
  String $group = 'pihole',
) {
  $full_installer_path = "${installer_path}/${installer_filename}"

  # Create pihole group
  group { $group:
    ensure => present,
    system => true,
  }

  # Create pihole user
  user { $user:
    ensure     => present,
    gid        => $group,
    system     => true,
    shell      => '/usr/sbin/nologin',
    home       => '/home/pihole',
    managehome => false,
    comment    => 'Pi-hole service user',
    require    => Group[$group],
  }

  # Ensure required packages are installed for the Pi-hole installer
  package { ['curl', 'ca-certificates']:
    ensure => present,
  }

  # Create Pi-hole config directory
  file { '/etc/pihole':
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }

  # COMMENTED OUT FOR INIFILE TESTING
  # # Manage pihole.toml configuration file using concat
  # concat { '/etc/pihole/pihole.toml':
  #   ensure  => present,
  #   mode    => '0644',
  #   owner   => $user,
  #   group   => $group,
  #   require => File['/etc/pihole'],
  # }

  # # Header fragment
  # concat::fragment { 'pihole_header':
  #   target  => '/etc/pihole/pihole.toml',
  #   content => epp('pihole/00_header.toml.epp'),
  #   order   => '00',
  # }

  # # DNS basic configuration fragment
  # concat::fragment { 'pihole_dns_basic':
  #   target  => '/etc/pihole/pihole.toml',
  #   content => epp('pihole/10_dns_basic.toml.epp', {
  #     'dns_servers'     => $dns_servers,
  #     'interface'       => $interface,
  #     'dns_domain'      => $dns_domain,
  #     'listening_mode'  => $listening_mode,
  #     'query_logging'   => $query_logging,
  #     'cache_size'      => $cache_size,
  #     'blocking_enabled'=> $blocking_enabled,
  #     'dns_advanced'    => $dns_advanced,
  #   }),
  #   order   => '10',
  # }

  # # DNS hosts fragment (only if hosts are defined)
  # if !empty($dns_hosts) {
  #   concat::fragment { 'pihole_dns_hosts':
  #     target  => '/etc/pihole/pihole.toml',
  #     content => epp('pihole/20_dns_hosts.toml.epp', {
  #       'dns_hosts' => $dns_hosts,
  #     }),
  #     order   => '20',
  #   }
  # }

  # # Webserver configuration fragment
  # if $webserver_enabled {
  #   concat::fragment { 'pihole_webserver':
  #     target  => '/etc/pihole/pihole.toml',
  #     content => epp('pihole/40_webserver.toml.epp', {
  #       'webserver_port'     => $webserver_port,
  #       'api_password_hash'  => $api_password_hash,
  #       'webserver_advanced' => $webserver_advanced,
  #     }),
  #     order   => '40',
  #   }
  # }

  # # DHCP configuration fragment
  # if $dhcp_enabled {
  #   concat::fragment { 'pihole_dhcp':
  #     target  => '/etc/pihole/pihole.toml',
  #     content => epp('pihole/50_dhcp.toml.epp', {
  #       'dhcp_config' => $dhcp_config,
  #     }),
  #     order   => '50',
  #   }
  # }

  # # NTP configuration fragment (only if NTP settings are defined)
  # if !empty($ntp_config) {
  #   concat::fragment { 'pihole_ntp':
  #     target  => '/etc/pihole/pihole.toml',
  #     content => epp('pihole/60_ntp.toml.epp', {
  #       'ntp_config' => $ntp_config,
  #     }),
  #     order   => '60',
  #   }
  # }

  # # Database configuration fragment (only if database settings are defined)
  # if !empty($database_config) {
  #   concat::fragment { 'pihole_database':
  #     target  => '/etc/pihole/pihole.toml',
  #     content => epp('pihole/70_database.toml.epp', {
  #       'database_config' => $database_config,
  #     }),
  #     order   => '70',
  #   }
  # }

  # # Misc and privacy settings fragment
  # concat::fragment { 'pihole_misc':
  #   target  => '/etc/pihole/pihole.toml',
  #   content => epp('pihole/90_misc.toml.epp', {
  #     'privacy_level' => $privacy_level,
  #     'misc_config'   => $misc_config,
  #   }),
  #   order   => '90',
  # }

  # # Debug configuration fragment (only if debug settings are defined)
  # if !empty($debug_config) {
  #   concat::fragment { 'pihole_debug':
  #     target  => '/etc/pihole/pihole.toml',
  #     content => epp('pihole/95_debug.toml.epp', {
  #       'debug_config' => $debug_config,
  #     }),
  #     order   => '95',
  #   }
  # }

  # TEST: Use inifile to manage a single setting
  ini_setting { 'pihole_blockTTL':
    ensure  => present,
    path    => '/etc/pihole/pihole.toml',
    section => 'dns',
    setting => 'blockTTL',
    value   => '5',
    require => [File['/etc/pihole'], Exec['install_pihole']],
  }

  # Download the Pi-hole installer (only if pihole not already installed)
  file { $full_installer_path:
    ensure => file,
    source => $installer_url,
    mode   => '0755',
  }

  # Execute the Pi-hole installer
  exec { 'install_pihole':
    command => "bash ${full_installer_path} --unattended",
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    user    => 'root',
    group   => 'root',
    unless  => 'test -f /usr/local/bin/pihole',
    require => [File[$full_installer_path], Package['curl', 'ca-certificates'], User[$user]],
    timeout => 0,
  }

  service { 'pihole-FTL':
    ensure    => 'running',
    enable    => 'true',
    #subscribe => Concat['/etc/pihole/pihole.toml'],
  }

}
