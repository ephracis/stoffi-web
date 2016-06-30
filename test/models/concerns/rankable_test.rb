# frozen_string_literal: true
require 'test_helper'

class RankableTest < ActiveSupport::TestCase
  test 'should rank by listens' do
    e = Media::Event.rank.limit 3
    assert_equal 2, e.length, "Didn't return two top events"
    assert e[0].listens.count >= e[1].listens.count,
           'Top events not in order (first and second, listens)'
  end
end
