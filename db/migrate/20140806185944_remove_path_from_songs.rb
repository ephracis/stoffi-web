# frozen_string_literal: true
class RemovePathFromSongs < ActiveRecord::Migration
  def change
    sql = 'select id,path,foreign_url from songs'
    rows = ActiveRecord::Base.connection.execute sql
    rows.each do |row|
      begin
        path = row[1]
        next if path.blank?
        if path.start_with? 'stoffi:track:youtube:'
          id = path[21..-1]
          name = 'youtube'

        elsif path.start_with? 'stoffi:track:soundcloud:'
          id = path[24..-1]
          name = 'soundcloud'

        elsif path.start_with? 'stoffi:track:jamendo:'
          id = path[21..-1]
          name = 'jamendo'

        else
          id = path
          name = 'local'
        end

        src = Source.new
        src.resource_tyoe = 'Song'
        src.resource_id = row[0]
        src.name = name
        src.foreign_id = id
        src.foreign_url = row[2]

      rescue
      end
    end
    remove_column :songs, :path, :string
    remove_column :songs, :foreign_url, :string
  end
end
