# Changelog

All notable changes to this project will be documented in this file.

## Release 3.3.0 (2024-11-29)

**Features**

- Update checksum for 1.22.4

**Fixes**

- Update deprecated function

**Chores**

- Update tested OS versions
- Vendor no longer builds for i386

## Release 3.2.0 (2024-02-23)

**Features**

- Support installing directly from URL

## Release 3.1.0 (2023-11-21)

**Features**

- Stage and check updates
- Service umask parameter
- Checksums added for releases up to 1.21.0

## Release 3.0.0 (2023-07-23)

**Features**

- Gitea 1.20+ support

**Fixes**

- Idempotency on install

**Breaking Changes**

- Drop support for Puppet 6

## Release 2.0.0 (2023-02-02)

**Features**

- `ensure` parameter accepts `latest`
  performs automatic incremental upgrades

**Breaking Changes**

- `version` class parameter changed to `ensure`

## Release 1.3.0 (2023-01-10)

**Features**

- Deploy Gitea 1.18.0

**Fixes**

- Manage owner of custom/app.ini

## Release 1.0.0 (2022-11-21)

**Features**

- Initial release

This is an incompatible fork of the kogitoapp/gitea module.
