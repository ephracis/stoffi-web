# frozen_string_literal: true
require 'test_helper'

class LinkBacklogTest < ActiveSupport::TestCase
  setup do
    @backlog = Accounts::LinkBacklog.new
    @backlog.resource = Media::Listen.first
    @backlog.link = Accounts::Link.first
  end

  test 'should create' do
    assert_difference 'Accounts::LinkBacklog.count', +1 do
      @backlog.save
    end
  end

  test 'should not create without resource' do
    @backlog.resource = nil
    assert_no_difference 'Accounts::LinkBacklog.count' do
      @backlog.save
    end
  end

  test 'should not create without link' do
    @backlog.link = nil
    assert_no_difference 'Accounts::LinkBacklog.count' do
      @backlog.save
    end
  end
end
