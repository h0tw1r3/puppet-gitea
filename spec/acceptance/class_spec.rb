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

    # FIXME: not working on rhel litmusimages (no ss command?)
    # describe port(3000) do
    #   it { is_expected.to be_listening }
    # end
  end
end
