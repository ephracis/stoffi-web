class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.references :follower, polymorphic: true, index: true
      t.references :followee, polymorphic: true, index: true
    end
    
    sql = "select playlist_id,user_id from playlist_subscribers"
    rows = ActiveRecord::Base.connection.execute sql
    rows.each do |row|
      s = "insert into followings (follower_type,follower_id,followee_type,followee_id) "+
        "VALUES ('User',#{row[1]},'Playlist',#{row[0]})"
      ActiveRecord::Base.connection.execute s
    end
  end
end
