# frozen_string_literal: true
require 'test_helper'

class BackendBaseTest < ActiveSupport::TestCase
  test 'should cast to string' do
    assert_equal Backends::Base.to_s, Backends::Base.new.to_s
  end
end
