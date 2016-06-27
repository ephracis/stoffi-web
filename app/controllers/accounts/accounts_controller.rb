# Copyright (c) 2015 Simplare

module Accounts
  
  # Handle requests for managing accounts.
  class AccountsController < Devise::RegistrationsController
    
    # hooks
    before_filter :set_resource, only: [ :show, :playlists ]
    before_filter :set_resource_for_update, only: [ :edit, :update ]
    before_filter :set_return_to, only: [ :new, :destroy ]

    oauthenticate except: [ :new, :create, :show ]

    # GET /join
    def new
      build_resource {}
      if request.format == :embedded
        render
      else
        render '/accounts/sessions/new'
      end
    end
  
    # POST /join
    def create
      if verify_recaptcha
        flash[:alert] = nil
        build_resource(sign_up_params)

        if resource.save
          yield resource if block_given?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
          
        else # save failed
          clean_up_passwords resource
          render '/users/sessions/new'
        end
        
      else # recaptcha failed
        #set_flash_message :notice, :failed_recaptcha
        build_resource
        clean_up_passwords(resource)
        render '/users/sessions/new'
      end
    end
  
    # GET /profile
    def show
    end
  
    # GET /dashboard
    def dashboard
      set_rankings
      ids = PublicActivity::Activity.pluck(:id).shuffle[0..19]
      @activities = PublicActivity::Activity.where(id: ids)
      #@activities = PublicActivity::Activity.order(created_at:
      #:desc).limit(20)
      @devices = current_user.devices
      respond_to do |format|
        format.html { render }
        format.json { render "accounts/accounts/dashboard/#{params[:tab]}" }
      end
    end
  
    # GET /settings
    def edit
      respond_to do |format|
        format.html { render action: "edit" }
        format.embedded { render action: "dashboard" }
      end
    end
  
    # PATCH /settings
    def update
      change_admin_protected_values if current_user.admin?
      
      if update_user
        
        # successfully updated
        respond_to do |format|
          format.html {
            sign_in @user, bypass: true
            redirect_to after_update_path_for(@user)
          }
          format.json { render json: @user }
        end
        
      else
        
        # failed to update
        add_breadcrumb I18n.t('breadcrumbs.settings'), settings_path
        respond_to do |format|
          format.html {
            render 'edit'
          }
          format.json {
            render json: @user.errors, status: :unprocessable_entity
          }
        end
      end
      
    end
  
    # DELETE /leave
    def destroy
      # TODO: send to connected devices
      resource.destroy
      set_flash_message :notice, :destroyed
      sign_out_and_redirect(self.resource)
    end

    protected
  
    # The URL where the user should return to after finishing updating the
    # account.
    def after_update_path_for(resource)
      edit_registration_path(resource)
    end
  
    private
    
    # Set the session variable `user_return_to` so that the user is returned
    # back to the previous page after finish a request.
    def set_return_to
      if request.referer and not request.referer.in? skip_return_to
        session["user_return_to"] = request.referer
      end
    end
    
    # A list of URLs which the user should not be returned to after finishing
    # a request.
    #
    # This is used to prevent users from being returned to intermediate steps
    # after finishing a registration or login flow.
    #
    # For example:
    # - User views a song
    # - User clicks on 'login' => previous URL is saved as `user_return_to`
    # - User clicks on 'forgot password' => previous URL is not saved
    # - User clicks on 'join' => previous URL is not saved
    # - User finishing registration => Returned to song
    def skip_return_to
      [user_session_url, user_registration_url, user_unlock_url,
        user_password_url]
    end
  
    # White list of parameters that the user is allowed to change for the
    # account.
    def resource_params
      params.require(:user).permit(:email, :password, :password_confirmation,
        :current_password, :avatar, :name, :name_source_id, :slug, :show_ads)
    end
  
    # Get the ID of the requested user.
    def get_user_id
      # treat `params[:user_slug]` as alias of `params[:id]`
      params[:id] = params[:user_slug] if params[:user_slug].present?
      
      # default to id of current user if missing, but require auth
      if params[:id].blank? and current_user.blank?
        redirect_to :new_user_session_path and return
      end
      params[:id] ||= current_user.id
    end
    
    # Get the user object in order to edit it.
    #
    # Normal users get their own user, admins can specify other users to edit.
    def set_resource_for_update
      params[:id] = get_user_id
      if params[:id] and current_user.admin?
        @resource = @user = User.friendly.find params[:id]
      else
        @resource = @user = current_user
      end
    end
    
    # Create an instance of the resource given the parameters.
    def set_resource
      @resource = @user = User.friendly.find get_user_id
    rescue
      raise params.inspect
    end
    
    # Change the values of `@user` that are available to admins only.
    #
    # Admins cannot change these values on themselves, though.
    def change_admin_protected_values
      return unless current_user.admin?
      return if @user == current_user
      if params[:user][:admin]
        @user.update_attribute(:admin, params[:user][:admin])
        params[:user].delete :admin
      end
      if params[:user][:locked_at]
        @user.update_attribute(:locked_at, params[:user][:locked_at])
        params[:user].delete :locked_at
      end
    end
    
    # Update the attributes of the user.
    def update_user
      return true if params[:user].blank?
      
      # change passwords
      if params[:edit_password].present?
        return @user.update_with_password resource_params
        
      # keep passwords
      else
        params[:user].delete :current_password
        return @user.update_without_password resource_params
      end
    end

    # Set the list of users that are around `current_user` in
    # the rankings, and the position of the first user in that
    # list.
    def set_rankings
      users = User.rank
      current_pos = users.find_index current_user
      start_pos = [0,current_pos-5].max
      length = current_pos < 6 ? 10 : 11
      @rank_users = users[start_pos,length]
      @start_ranking = start_pos + 1
    end
    
  end # class 
end # module
