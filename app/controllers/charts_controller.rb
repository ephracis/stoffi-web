class ChartsController < ApplicationController
	
	oauthenticate
	before_filter :verify_admin, except: [:listens_for_user, :songs_for_user, :albums_for_user,
		:artists_for_user, :playlists_for_user, :genres_for_user, :top_listeners]
	
	def listens_for_user
		render json: current_user.listens.where("created_at > ?", 1.year.ago).group_by_day(:created_at)
	end

	def songs_for_user
		@songs = Song.top(for: current_user, empty: false).limit(10)
	end

	def artists_for_user
		render json: Artist.top(for: current_user, empty: false).limit(10).
			map { |x| [x.name,x.listens_count] }.to_h
	end

	def albums_for_user
		render json: Album.top(for: current_user, empty: false).limit(10).
			map { |x| [x.title,x.listens_count] }.to_h
	end

	def playlists_for_user
		render json: Playlist.top(for: current_user, empty: false).limit(10).
			map { |x| [x.name,x.listens_count] }.to_h
	end

	def genres_for_user
		render json: Genre.top(for: current_user, empty: false).limit(10).
			map { |x| [x.name,x.listens_count] }.to_h
	end
	
	def top_listeners
		begin
			start = params[:start].to_date
		rescue
			start = DateTime.strptime('0', '%s')
		end
		render json: User.rank(:listens, start: start).
			limit(10).
			map { |x| [x.name,x.listens_count] }.to_h
	end

	def active_users
		render json: User.group(:email).order(sign_in_count: :desc).limit(10).sum(:sign_in_count)
	end
	
	private
	
	def verify_admin
		return true if signed_in? and current_user.admin?
		
		respond_to do |format|
			format.html { redirect_to :new_user_session }
			format.json { head :forbidden }
			format.xml { head :forbidden }
		end
	end
	
end