require 'spec_helper'

describe 'gitea', type: :class do
  let :pre_condition do
    'file { "foo.rb":
      ensure => present,
      path   => "/etc/tmp",
      notify => Class["gitea::service"] }'
  end

  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to contain_class('gitea') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('gitea::service::user').that_comes_before('Class[gitea::install]') }
        it { is_expected.to contain_class('gitea::install').that_comes_before('Class[gitea::config]') }
        it { is_expected.to contain_class('gitea::install').that_notifies('Class[gitea::service]') }
        it { is_expected.to contain_class('gitea::config').that_notifies('Class[gitea::service]') }
        it { is_expected.to contain_class('gitea::service') }

        it { is_expected.to contain_file('foo.rb').that_notifies('Class[gitea::service]') }

        # gitea::install
        it { is_expected.to contain_archive('gitea') }

        it { is_expected.to contain_file('/opt/gitea') }
        it { is_expected.to contain_file('/opt/gitea/gitea') }
        it { is_expected.to contain_file('/opt/gitea/data') }
        it { is_expected.to contain_file('/opt/gitea/data/gitea-repositories') }
        it { is_expected.to contain_file('/opt/gitea/data/sessions') }

        it { is_expected.to contain_systemd__unit_file('gitea.service') }
        it { is_expected.to contain_systemd__tmpfile('gitea.conf') }

        ['curl', 'git', 'tar'].each do |package_name|
          it { is_expected.to contain_package(package_name) }
        end

        # gitea::config
        it { is_expected.to contain_file('/opt/gitea/custom') }
        it { is_expected.to contain_file('/opt/gitea/custom/conf') }
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
            'log' => {
              'DISABLE_ROUTER_LOG' => 'true'
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

        # gitea::service::user
        it { is_expected.to contain_user('git') }
        it { is_expected.to contain_group('git') }
      end
    end
  end
end
