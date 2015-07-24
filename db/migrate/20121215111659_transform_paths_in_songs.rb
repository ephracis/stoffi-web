class TransformPathsInSongs < ActiveRecord::Migration
  def up
    sql = "select id,path from songs"
    rows = ActiveRecord::Base.connection.execute sql
    rows.each do |row|
      song_id = row[0]
      path = row[1]
      path_name = path[0 .. path.index('://')-1]
      path_id = path[path.index('://')+3 .. -1]
      path = "stoffi:track:#{path_name}:#{path_id}"
      ActiveRecord::Base.connection.execute "update songs set path='#{path}' where id=#{song_id}"
    end
  end
end
