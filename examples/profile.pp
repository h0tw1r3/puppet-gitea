# @summary example gitea profile
#
# @param root_url
#   This is useful if the internal and the external URL don't match (e.g. docker, load balancer, reverse proxy)
# @param app_name
#   Application name, used in the page title
# @param redis_cache
#   enable caching in redis
# @param redis_session
#   enable redis session storage
#
# @example
#   include profile::gitea
#
# lint:ignore:autoloader_layout
class profile::gitea (
# lint:endignore
  String $root_url = '%(PROTOCOL)s://%(DOMAIN)s:%(HTTP_PORT)s/',
  String $app_name = 'Gitea: Git with a cup of tea',
  Boolean $redis_cache = false,
  Boolean $redis_session = false,
) {
  if $redis_session or $redis_cache {
    package { 'redis-server':
      ensure => installed,
    }
  }

  $config_session = $redis_session ? {
    true    => {
      'PROVIDER'        => 'redis',
      'PROVIDER_CONFIG' => 'network=tcp,addr=127.0.0.1:6379,db=0,pool_size=100,idle_timeout=180',
    },
    default => {},
  }

  $config_cache = $redis_cache ? {
    true    => {
      'ADAPTER' => 'redis',
      'HOST'    => 'network=tcp,addr=127.0.0.1:6379,db=0,pool_size=100,idle_timeout=180',
    },
    default => {},
  }

  class { 'gitea':
    custom_configuration => {
      ''            => {
        'APP_NAME' => $app_name,
      },
      'server'      => {
        'ROOT_URL' => $root_url,
      },
      'log.console' => {
        'FLAGS' => 'levelinitial',
      },
      'ui'          => {
        'SHOW_USER_EMAIL'       => 'false',
        'MAX_DISPLAY_FILE_SIZE' => '4194304',
      },
      'ui.meta'     => {
        'AUTHOR'      => 'Gitea',
        'DESCRIPTION' => 'Software Projects',
        'KEYWORDS'    => 'git,self-hosted',
      },
      'indexer'     => {
        'REPO_INDEXER_ENABLED' => true,
      },
      'cache'       => $config_cache,
      'session'     => $config_session,
    },
  }

  gitea::custom::file { 'public/assets/css/custom.css':
    content => @(EOD)
      body {
        font-face: Helvetica
      }
      | EOD
    ,
  }
}
