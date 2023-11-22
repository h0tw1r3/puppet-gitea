require 'spec_helper'

_, os_facts = on_supported_os.first

describe 'gitea', type: :class do
  let :pre_condition do
    'file { "foo.rb":
      ensure => present,
      path   => "/etc/tmp",
      notify => Class["gitea::service"] }'
  end

  let(:facts) { os_facts }

  # gitea
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_class('gitea') }
  it { is_expected.to contain_class('gitea::service::user').that_comes_before('Class[gitea::install]') }
  it { is_expected.to contain_class('gitea::install').that_comes_before('Class[gitea::config]') }
  it { is_expected.to contain_class('gitea::install').that_notifies('Class[gitea::service]') }
  it { is_expected.to contain_class('gitea::config').that_notifies('Class[gitea::service]') }
  it { is_expected.to contain_class('gitea::service') }

  it { is_expected.to contain_file('foo.rb').that_notifies('Class[gitea::service]') }

  # gitea::install
  it {
    is_expected.to contain_archive('gitea')
      .with(
        path: '/opt/gitea/gitea.stage',
        source: %r{https://dl.gitea.io/gitea/.*/gitea-.*},
        checksum: %r{^[a-z0-9]{64}$},
        checksum_type: 'sha256',
        cleanup: false,
        extract: false,
      )
  }

  [
    '/opt/gitea',
    '/opt/gitea/data',
    '/opt/gitea/data/gitea-repositories',
    '/opt/gitea/data/sessions',
  ].each do |path|
    # rubocop:disable RSpec/RepeatedExample
    it {
      is_expected.to contain_file(path)
        .with_ensure('directory')
        .with_owner('git')
        .with_group('git')
    }
    # rubocop:enable RSpec/RepeatedExample
  end

  it {
    is_expected.to contain_file('/opt/gitea/gitea.stage')
      .with_mode('0755')
  }

  it {
    is_expected.to contain_exec('gitea-release-check')
      .with_cwd('/opt/gitea')
      .with_environment(
        [
          'HOME=/opt/gitea',
          'USER=git',
          'GITEA_WORK_DIR=/opt/gitea',
        ],
      )
      .with_user('git')
      .with_umask('0027')
      .with_command("/opt/gitea/gitea.stage doctor check --run paths --log-file '' || /opt/gitea/gitea.stage doctor --run paths --log-file ''")
      .with_onlyif(
        [
          '/usr/bin/env test -f /opt/gitea/custom/conf/app.ini',
          '/usr/bin/env cmp /opt/gitea/gitea /opt/gitea/gitea.stage; /usr/bin/env test $? -eq 1',
        ],
      )
  }

  it {
    is_expected.to contain_file('/opt/gitea/gitea')
      .with_source('/opt/gitea/gitea.stage')
      .with_mode('0755')
  }

  ['curl', 'git', 'tar'].each do |package_name|
    it { is_expected.to contain_package(package_name) }
  end

  # gitea::config
  [
    '/opt/gitea/custom',
    '/opt/gitea/custom/conf',
  ].each do |path|
    # rubocop:disable RSpec/RepeatedExample
    it {
      is_expected.to contain_file(path)
        .with_ensure('directory')
        .with_owner('git')
        .with_group('git')
    }
    # rubocop:enable RSpec/RepeatedExample
  end

  it {
    is_expected.to contain_file('/opt/gitea/custom/conf/app.ini')
      .with_owner('git')
      .with_group('git')
      .with_mode('0600')
  }

  it do
    config_path = '/opt/gitea/custom/conf/app.ini'
    config_expect = {
      '' => {
        'RUN_USER' => 'git',
      },
      'database' => {
        'DB_TYPE' => 'sqlite3',
        'LOG_SQL' => 'false'
      },
      'actions' => {
        'ENABLED' => 'true',
        'DEFAULT_ACTIONS_URL' => 'github'
      },
      'log' => {
        'logger.router.MODE' => nil
      },
      'repository' => {
        'ROOT' => '/opt/gitea/data/gitea-repositories'
      },
      'security' => {
        'INSTALL_LOCK' => 'true'
      },
      'server' => {
        'APP_DATA_PATH' => '/opt/gitea/data'
      }
    }

    config_expect.each do |section, keys|
      keys.each do |key, value|
        is_expected.to contain_ini_setting("#{config_path} [#{section}] #{key}").with(
          section: section,
          setting: key,
          value: value,
          path: config_path,
        )
      end
    end
  end

  # gitea::service
  it {
    is_expected.to contain_systemd__tmpfile('gitea.conf')
      .with_content(%r{^d /run/gitea 0751 git git$})
  }
  it {
    is_expected.to contain_systemd__unit_file('gitea.service')
      .that_requires('Class[gitea::config]')
      .with_enable(true)
      .with_active(true)
  }

  # gitea::service::user
  it {
    is_expected.to contain_group('git')
      .with_ensure('present')
      .with_system(true)
  }
  it {
    is_expected.to contain_user('git')
      .that_requires('Group[git]')
      .that_notifies('Systemd::Tmpfile[gitea.conf]')
      .with_ensure('present')
      .with_gid('git')
      .with_home('/home/git')
      .with_managehome(true)
      .with_system(true)
  }
end
