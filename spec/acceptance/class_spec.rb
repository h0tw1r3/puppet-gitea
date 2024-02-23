require 'spec_helper_acceptance'

describe 'gitea class' do
  context 'with default parameters' do
    let(:pp) do
      <<-MANIFEST
      class { 'gitea': }
      MANIFEST
    end

    it 'behaves idempotently' do
      idempotent_apply(pp)
    end

    describe group('git') do
      it { is_expected.to exist }
    end

    describe user('git') do
      it { is_expected.to exist }
    end

    describe file('/opt/gitea') do
      it { is_expected.to be_directory }
    end

    describe file('/opt/gitea/custom') do
      it { is_expected.to be_directory }
    end

    describe file('/opt/gitea/custom/conf') do
      it { is_expected.to be_directory }
    end

    describe file('/opt/gitea/custom/conf/app.ini') do
      it { is_expected.to be_file }
    end

    describe file('/opt/gitea/data') do
      it { is_expected.to be_directory }
    end

    describe file('/opt/gitea/data/attachments') do
      it { is_expected.to be_directory }
    end

    describe file('/opt/gitea/gitea') do
      it { is_expected.to be_file }
    end

    describe service('gitea') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(3000) do
      it { is_expected.to be_listening }
    end
  end

  context 'install custom version' do
    let(:pp) do
      <<-MANIFEST
      class { 'gitea':
        ensure   => 'https://codeberg.org/forgejo/forgejo/releases/download/v1.21.6-0/forgejo-1.21.6-0-linux-amd64',
        checksum => 'e86f446236a287b9ba2c65f8ff7b0a9ea4f451a5ffc3134f416f751e1eecf97c',
      }
      MANIFEST
    end

    it 'behaves idempotently' do
      idempotent_apply(pp)
    end
  end
end
