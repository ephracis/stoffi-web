class AddNameSourceRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :name_source, index: true, foreign_key: true
  end
end
