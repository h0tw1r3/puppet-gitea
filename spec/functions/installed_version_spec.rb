# frozen_string_literal: true

require 'spec_helper'

describe 'gitea::installed_version' do
  # please note that these tests are examples only
  # you will need to replace the params and return value
  # with your expectations
  it { is_expected.to run.with_params('/opt/gitea/gitea').and_return(nil) }
  it { is_expected.to run.with_params(nil).and_raise_error(StandardError) }
end
