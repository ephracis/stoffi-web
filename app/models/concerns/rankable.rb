module Rankable
	extend ActiveSupport::Concern
	
	module ClassMethods
		
		def rank(association, options = {})
			options = {
				start: DateTime.strptime('0', '%s')
			}.merge(options)
		    tname = self.name.tableize
			key = "#{self.name.parameterize}_id"
			
		    self.select("#{tname}.*,COUNT(#{association}.id) AS #{association}_count").
				joins("LEFT JOIN #{association} AS #{association} ON #{association}.#{key} = #{tname}.id "+
					"AND #{association}.created_at > #{ActiveRecord::Base.connection.quote(options[:start])}").
				group("#{tname}.id").
				order("#{association}_count DESC")
		end
	
		# Returns the objects sorted by number of listens and popularity
		#
		# options:
		#   for: If this is specified, listens only for this user are
		#        counted
		def top(options = {})
			
			# default options
			options = {
				empty: true
			}.merge(options)
			
		    tname = self.name.tableize
			songs_tname = self.name == 'Song' ? 'songs' : 'top_songs'

		    inner_select = self.select("#{tname}.*,COUNT(DISTINCT(top_listens.id)) AS listens_count")
		
			# for events we join in songs via artists
			if self.name == 'Event'
		    	inner_select = inner_select.
					joins("LEFT JOIN performances AS top_performances ON top_performances.event_id = events.id").
					joins("LEFT JOIN artists AS top_artists ON top_artists.id = top_performances.artist_id").
					joins("LEFT JOIN artists_songs AS top_artists_songs ON top_artists_songs.artist_id = top_artists.id").
					joins("LEFT JOIN songs AS top_songs ON top_songs.id = top_artists_songs.song_id")
					
			# here we assume that the resource has a habtm relation to songs via a join table using a default name
			elsif self.name != 'Song'
		    	inner_select = inner_select.
					joins("LEFT JOIN #{tname}_songs AS top_#{tname}_songs ON top_#{tname}_songs.#{self.name}_id = #{tname}.id").
					joins("LEFT JOIN songs AS top_songs ON top_songs.id = top_#{tname}_songs.song_id")
			end
			
			join_type = 'LEFT'
			join_type = 'INNER' unless options[:empty]
			listen_scope = ''
			listen_scope = " AND top_listens.user_id = %s" % ActiveRecord::Base.connection.quote(options[:for].id) if options[:for].is_a? User
			inner_select = inner_select.
				joins("#{join_type} JOIN listens AS top_listens ON top_listens.song_id = #{songs_tname}.id"+listen_scope).
				group("#{tname}.id")
			
			#inner_select = inner_select.where("top_listens.user_id = ?", options[:for].id) if options[:for].is_a? User

			select("#{tname}.*,#{tname}.listens_count,SUM(top_sources.popularity) AS popularity_count").
				from(inner_select, tname).
				joins("LEFT JOIN sources AS top_sources ON top_sources.resource_id = #{tname}.id AND top_sources.resource_type = '#{self.name}'").
				group("#{tname}.id").
				order("listens_count DESC, popularity_count DESC")
		end
		
		# TODO: do we really need this? it's broken anyway
		def top?
			self.name == 'Song' ? any? : joins(:songs).any?
		end
		
	end
end