# frozen_string_literal: true
module SyncHelper
  def channels
    c = @channels.uniq if @channels
    c = [] unless c

    if current_user
      c << "hash_#{current_user.unique_hash}"
      c.delete("user_#{current_user.id}")
    end

    c.uniq
  end
end
