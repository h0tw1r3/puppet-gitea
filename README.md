# puppet-gitea

[![Build Status][build-shield]][build-status]
[![Puppet Forge][forge-shield]][forge-gitea]
[![Puppet Forge - downloads][forge-shield-dl]][forge-gitea]
[![Puppet Forge - scores][forge-shield-sc]][forge-gitea]

## Description

A Puppet module for managing [Gitea][gitea] (Git with a cup of tea) settings.
This module allows you to install and configure Gitea using pre-built binaries
and does not need external package repositories. You can chose to install Gitea
with default settings, or customize all settings to your liking.

## Setup

### What Gitea affects

- `puppet-gitea` depends on
  - [puppetlabs-stdlib][puppetlabs-stdlib],
  - [puppetlabs-inifile][puppetlabs-inifile],
  - [puppet-archive][puppet-archive],
  - [puppet-extlib][puppet-extlib],
- it manages a user and group `git`
- it manages the gitea working directory
- it install a `gitea` service listening on port `3000`

### Beginning with Gitea

The simplest use case is to rely on defaults. This can be done by simply
including the class:

```puppet
include gitea
```

To install a specific version, you must provide the sha256 checksum:

```puppet
class { 'gitea':
  version  => '1.17.0',
  checksum => 'bc4a8e1f5d5f64d4be2e50c387de08d07c062aecdba2f742c2f61c20accfcc46',
}
```

## Limitations

See [metadata.json](metadata.json) for supported platforms.

## Development

### Running tests

This project contains tests for [rspec-puppet][puppet-rspec].

Quickstart:

```console
gem install bundler
bundle install
bundle exec rake test
```

When submitting pull requests, please make sure that module documentation,
test cases and syntax checks pass.

[gitea]: https://github.com/go-gitea/gitea
[puppetlabs-stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppetlabs-inifile]: https://github.com/puppetlabs/puppetlabs-inifile
[puppet-archive]: https://github.com/voxpupuli/puppet-archive
[puppet-extlib]: https://github.com/voxpupuli/puppet-extlib
[puppet-rspec]: http://rspec-puppet.com/

[build-status]: https://travis-ci.org/h0tw1r3/puppet-gitea
[build-shield]: https://travis-ci.org/h0tw1r3/puppet-gitea.png?branch=main
[forge-gitea]: https://forge.puppetlabs.com/h0tw1r3/gitea
[forge-shield]: https://img.shields.io/puppetforge/v/h0tw1r3/gitea.svg
[forge-shield-dl]: https://img.shields.io/puppetforge/dt/h0tw1r3/gitea.svg
[forge-shield-sc]: https://img.shields.io/puppetforge/f/h0tw1r3/gitea.svg
