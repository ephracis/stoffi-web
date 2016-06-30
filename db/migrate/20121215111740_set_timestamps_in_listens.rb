# frozen_string_literal: true
class SetTimestampsInListens < ActiveRecord::Migration
  def up
    Media::Listen.all.each do |listen|
      listen.started_at = listen.created_at if listen.started_at.nil?
      if listen.ended_at.nil? && !listen.song.nil? && !listen.song.length.nil?
        listen.ended_at = listen.started_at + listen.song.length
      end
      listen.save
    end
  end

  def down
  end
end
