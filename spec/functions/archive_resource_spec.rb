# frozen_string_literal: true

require 'spec_helper'

describe 'gitea::archive_resource' do
  # TODO
  it { is_expected.to run.with_params('/opt/gitea/gitea').and_raise_error(StandardError) }
end
