# frozen_string_literal: true

require 'spec_helper'

shared_examples 'gitea::custom::file' do |title, args|
  let(:title) { title }
  let(:params) { args }

  if title.include?('/')
    parts = title.split('/')[0..-2]
    parts.map.with_index { |v, i| (i > 0) ? parts.slice(0, i + 1).join('/') : v }.each do |apath|
      it {
        option = (params[:ensure] != 'absent') ? 'to' : 'not_to'
        is_expected.method(option).call contain_file("/opt/gitea/custom/#{apath}")
          .with_ensure('directory')
          .with_owner('git')
          .with_group('git')
      }
    end
  end

  it {
    is_expected.to contain_file("/opt/gitea/custom/#{title}")
      .with(
        ensure: params[:ensure],
        content: params[:content],
        source: params[:source],
        owner: 'git',
        group: 'git',
        recurse: false,
      )
  }
end

describe 'gitea::custom::file' do
  let(:title) { 'namevar' }

  it { is_expected.not_to compile }

  context 'with content' do
    include_examples 'gitea::custom::file', 'namevar', { ensure: 'file', content: 'test' }

    context 'with subdirectory' do
      include_examples 'gitea::custom::file', 'blah/blah/blah.css', { ensure: 'file', content: 'testing' }
    end
  end

  context 'with source' do
    include_examples 'gitea::custom::file', 'one/two.css', { source: 'puppet:///modules/profile/test.css' }
  end

  context 'absent' do
    include_examples 'gitea::custom::file', 'three/four.css', { ensure: 'absent' }
  end
end
