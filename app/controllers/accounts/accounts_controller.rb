# Copyright (c) 2015 Simplare

module Accounts
  
  # Handle requests for managing accounts.
  class AccountsController < Devise::RegistrationsController
    
    before_filter :get_profile_id, only: [ :show, :playlists ]
    before_filter :set_return_to, only: [ :new, :destroy ]

    oauthenticate except: [ :new, :create, :show ]
    
    respond_to :html, :json, :embedded

    # GET /join
    def new
      build_resource {}
      if request.format == :embedded
        render
      else
        render '/accounts/sessions/new', layout: 'fullwidth'
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
          render '/users/sessions/new', layout: 'fullwidth'
        end
        
      else # recaptcha failed
        #set_flash_message :notice, :failed_recaptcha
        build_resource
        clean_up_passwords(resource)
        render '/users/sessions/new', layout: 'fullwidth'
      end
    end
  
    # GET /profile
    def show
      @user = User.find params[:id]
      respond_with @user
    end
  
    # GET /dashboard
    def dashboard
      render layout: (params[:format] == 'embedded' ? 'empty' : true)
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
      @user = get_user
      change_admin_flag_if_admin
      
      if update_user
        
        # successfully updated
        respond_to do |format|
          format.html {
            sign_in @user, bypass: true
            redirect_to after_update_path_for(@user)
          }
          format.json { render json: @user }
          format.embedded { render }
        end
        
      else
        
        # failed to update
        respond_to do |format|
          format.html {
            prepare_settings
            render 'edit'
          }
          format.json {
            render json: @user.errors, status: :unprocessable_entity
          }
          format.embedded { render }
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
        :current_password, :image, :name_source, :custom_name, :show_ads)
    end
  
    # Get the ID of the requested user. Processes the special ID `me` to the ID
    # of the current user.
    def get_profile_id
      params[:id] = process_me(params[:id])
    end
    
    # Get the user object to edit.
    #
    # Normal users get their own user, admins can specify other users to edit.
    def get_user
      if params[:id] and current_user.admin?
        User.find params[:id]
      else
        current_user
      end
    end
    
    # Change the admin status of `@user`.
    #
    # Only admins can change the admin flag and they can only change the admin
    # flag of other users.
    def change_admin_flag_if_admin
      return unless current_user.admin?
      return if @user == current_user
      return unless params[:user][:admin]
      @user.update_attribute(:admin, params[:user][:admin])
      params[:user].delete :admin
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
  
    # def prepare_settings
    #     
    #       @new_links = Link.available.map do |link|
    #         
    #       end
    #       Link.available.each do |link|
    #         n = link[:name]
    #         ln = link[:link_name] || n.downcase
    #         if current_user.links.find_by(provider: ln) == nil
    #           img = "auth/#{n.downcase}_14_white"
    #           title = t("auth.link", service: n)
    #           path = "/auth/#{ln}"
    #           @new_links <<
    #           {
    #             name: n,
    #             img: img,
    #             title: title,
    #             path: path
    #           }
    #         end
    #       end
    #     
    #     end
    
  end # class 
end # module