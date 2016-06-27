class AddSlugToResources < ActiveRecord::Migration
  def change
    [:songs, :genres, :events, :albums, :apps].each do |r|
      add_column r, :slug, :string
      add_index r, :slug, unique: true
    end
    
    add_column :devices, :slug, :string
    add_index :devices, [:slug, :user_id], unique: true
  end
end
