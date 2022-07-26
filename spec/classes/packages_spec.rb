require 'spec_helper'

describe 'gitea::packages', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with :osfamily => "Debian"' do
        if facts[:os][:family] == 'Debian'
          let :params do
            {
              dependencies: ['curl', 'git', 'tar'],
              dependencies_ensure: 'present',
            }
          end

          it { is_expected.to contain_package('curl') }
          it { is_expected.to contain_package('git') }
          it { is_expected.to contain_package('tar') }
        end
      end

      context 'with :osfamily => "RedHat"' do
        if facts[:os][:family] == 'RedHat'
          let :params do
            {
              dependencies: ['curl', 'git', 'initscripts', 'tar'],
              dependencies_ensure: 'present',
            }
          end

          it { is_expected.to contain_package('curl') }
          it { is_expected.to contain_package('git') }
          it { is_expected.to contain_package('initscripts') }
          it { is_expected.to contain_package('tar') }
        end
      end
    end
  end
end
