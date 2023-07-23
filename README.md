# puppet-gitea

[![Build Status][workflow-ci-badge]][workflow-ci]
[![Release Status][workflow-release-badge]][workflow-release]
[![Puppet Forge][forge-badge]][forge-gitea]
[![Puppet Forge - downloads][forge-badge-dl]][forge-gitea]
[![Puppet Forge - scores][forge-badge-sc]][forge-gitea]
[![License][license-badge]](LICENSE)

## Setup

This module downloads a pre-built binary from the [Gitea] project releases
page. No external package repositories are required. You can choose to install
[Gitea] with default settings, or customize them using the
`custom_configuration` class parameter.

### Examples

The simplest use case is to rely on defaults, which will install the latest
tested version in `/opt/gitea`.

```puppet
include gitea
```

To install a version that has not been tested with this module, you must
provide the release _sha256_ checksum:

```puppet
class { 'gitea':
  version  => '1.17.0',
  checksum => 'bc4a8e1f5d5f64d4be2e50c387de08d07c062aecdba2f742c2f61c20accfcc46',
}
```

To customize the [Gitea] configuration, use the `custom_configuration` parameter
(merged with defaults in [common.yaml]).

Refer to Gitea's [Config Cheat Sheet] for most settings and defaults.
Each section in the cheat sheet is labeled by a human name and the
**config section** in parentheses. The _config section_ is a top level key
of the `custom_configuration` hash, except _DEFAULT_ which is an empty string.

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

[Custom files] allow you to add themes, override built-in templates, or serve
additional files.

Use the `gitea::custom::file` resource to manage files in Gitea's _custom_
directory. Subdirectories are automatically created for you.

```puppet
gitea::custom::file { 'public/css/custom.css':
  content => file('profile/gitea/custom.css'),
}
gitea::custom::file { 'public/img/logo.svg':
  source => 'puppet:///modules/profile/gitea/logo.svg',
}
```

## Tests

When submitting pull requests, please make sure that the module documentation,
test cases, and syntax checks pass.

Use the [PDK] to validate and execute unit tests:

```console
pdk validate
pdk test unit
```

Use the [PDK] to execute acceptance tests (__requires docker__):

```console
pdk bundle exec rake acceptance
```

Use the [PDK] to update the [reference] documentation.

```console
pdk bundle exec rake strings:generate:reference
```

## Acknowledgements

This module was forked from [kogitoapp/gitea] and _is *NOT* compatible_.


[Gitea]: https://github.com/go-gitea/gitea
[PDK]: https://puppet.com/docs/pdk/2.x/pdk.html

[workflow-ci]: https://github.com/h0tw1r3/puppet-gitea/actions/workflows/ci.yml
[workflow-ci-badge]: https://github.com/h0tw1r3/puppet-gitea/actions/workflows/ci.yml/badge.svg
[workflow-release]: https://github.com/h0tw1r3/puppet-gitea/actions/workflows/release.yml
[workflow-release-badge]: https://github.com/h0tw1r3/puppet-gitea/actions/workflows/release.yml/badge.svg

[forge-gitea]: https://forge.puppetlabs.com/h0tw1r3/gitea
[forge-badge]: https://img.shields.io/puppetforge/v/h0tw1r3/gitea.svg
[forge-badge-dl]: https://img.shields.io/puppetforge/dt/h0tw1r3/gitea.svg
[forge-badge-sc]: https://img.shields.io/puppetforge/f/h0tw1r3/gitea.svg

[license-badge]: https://img.shields.io/badge/License-Apache_2.0-blue.svg

[kogitoapp/gitea]: https://forge.puppet.com/modules/kogitoapp/gitea
[reference]: REFERENCE.md
[Custom files]: https://docs.gitea.io/en-us/customizing-gitea/
[common.yaml]: data/common.yaml
[Config Cheat Sheet]: https://docs.gitea.com/next/administration/config-cheat-sheet
