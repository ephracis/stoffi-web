require 'test_helper'

class RankableTest < ActiveSupport::TestCase
  
  test "should rank by listens and popularity" do
    e = Media::Event.top limit: 3
    assert_equal 3, e.length, "Didn't return three top events"
    assert e[0].listens.count == e[1].listens.count, "Top events not in order (first and second, listens)"
    assert e[0].popularity    >= e[1].popularity, "Top events not in order (first and second, popularity)"
    assert e[1].listens.count >= e[2].listens.count, "Top events not in order (second and third)"
  end
  
end