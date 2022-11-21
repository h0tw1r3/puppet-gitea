# puppet-gitea

[![Build Status][build-shield]][build-status]
[![Puppet Forge][forge-shield]][forge-gitea]
[![Puppet Forge - downloads][forge-shield-dl]][forge-gitea]
[![Puppet Forge - scores][forge-shield-sc]][forge-gitea]

## Setup

This module downloads a pre-built binary from the [Gitea] project releases
page. No external package repositories are required. You can choose to install
[Gitea] with default settings, or customize them using the
`custom_configuration` class parameter.

### Examples

The simplest use case is to rely on defaults. This can be done by simply
including the class:

```puppet
include gitea
```

To install a specific version, you must provide the _sha256_ checksum:

```puppet
class { 'gitea':
  version  => '1.17.0',
  checksum => 'bc4a8e1f5d5f64d4be2e50c387de08d07c062aecdba2f742c2f61c20accfcc46',
}
```

Custom configuration example:

```puppet
class { 'gitea':
  custom_configuration => {
    ''        => {
      'APP_NAME' => 'Internal Code Projects',
    },
    'server'  => {
      'ROOT_URL' => 'https://example.com/git/',
    },
    'ui'      => {
      'SHOW_USER_EMAIL'       => 'false',
      'MAX_DISPLAY_FILE_SIZE' => '4194304',
    },
    'ui.meta' => {
      'DESCRIPTION' => 'My self-hosted code project service',
      'KEYWORDS'    => 'git,self-hosted',
    },
    'indexer' => {
      'REPO_INDEXER_ENABLED' => true,
    },
    'cache'   => {
      'ADAPTER' => 'redis',
      'HOST'    => 'network=tcp,addr=127.0.0.1:6379,db=0,pool_size=100,idle_timeout=180',
    },
    'session' => {
      'PROVIDER'        => 'redis',
      'PROVIDER_CONFIG' => 'network=tcp,addr=127.0.0.1:6379,db=0,pool_size=100,idle_timeout=180',
    },
  }
}
```

If you need to support [custom files], use the `gitea::custom::file` resource:

```puppet
gitea::custom::file { 'public/css/custom.css':
  source => 'puppet:///modules/profile/gitea/custom.css',
}
gitea::custom::file { 'public/img/logo.svg':
  source => 'puppet:///modules/profile/gitea/logo.svg',
}
```

## Tests

When submitting pull requests, please make sure that the module documentation,
test cases, and syntax checks pass.

Use the [PDK] to validate and execute tests:

```console
pdk validate
pdk test unit
```

Use the [PDK] to update the [reference] documentation.

```console
pdk bundle exec rake strings:generate:reference
```

## Acknowledgements

lThis module was forked from [kogitoapp/gitea] and _is *NOT* compatible_.


[Gitea]: https://github.com/go-gitea/gitea
[PDK]: https://puppet.com/docs/pdk/2.x/pdk.html

[build-status]: https://travis-ci.org/h0tw1r3/puppet-gitea
[build-shield]: https://travis-ci.org/h0tw1r3/puppet-gitea.png?branch=main
[forge-gitea]: https://forge.puppetlabs.com/h0tw1r3/gitea
[forge-shield]: https://img.shields.io/puppetforge/v/h0tw1r3/gitea.svg
[forge-shield-dl]: https://img.shields.io/puppetforge/dt/h0tw1r3/gitea.svg
[forge-shield-sc]: https://img.shields.io/puppetforge/f/h0tw1r3/gitea.svg

[kogitoapp/gitea]: https://forge.puppet.com/modules/kogitoapp/gitea
[reference]: REFERENCE.md
[custom files]: https://docs.gitea.io/en-us/customizing-gitea/
