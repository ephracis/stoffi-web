class AddLengthToSources < ActiveRecord::Migration
	def change
		add_column :sources, :length, :decimal
		sql = "select id,length from songs"
		rows = ActiveRecord::Base.connection.execute sql
		rows.each do |row|
			s = "update sources set length=#{row[1]} where resource_type='Song' and resource_id=#{row[0]}"
			ActiveRecord::Base.connection.execute s
		end
	end
end
