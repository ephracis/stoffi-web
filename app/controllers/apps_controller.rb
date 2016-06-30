# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Handle requests for managing apps.
class AppsController < ApplicationController
  oauthenticate except: [:index, :show]
  oauthenticate interactive: true, only: [:update, :create, :destroy]
  before_action :set_app, only: [:show, :edit, :update, :destroy, :revoke]
  before_action :ensure_owner_or_admin, only: [:edit, :update, :destroy]

  # GET /apps
  def index
    l, o = pagination_params
    @apps = App.order(created_at: :desc).limit(l).offset(o)

    if user_signed_in?
      @created = current_user.get_apps(:created)
      @added = current_user.get_apps(:added)
    end
  end

  # GET /apps/new
  def new
    @app = App.new
  end

  # POST /apps
  def create
    @app = current_user.apps.new(app_params)

    respond_to do |format|
      if @app.save
        format.html { redirect_to @app }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /apps/1
  def show
    @channels = @app.user.blank? ? [] : ["user_#{@app.user.id}"]
    # @app.similar
  end

  # GET /apps/1/edit
  def edit
  end

  # PUT /apps/1
  def update
    respond_to do |format|
      if @app.update_attributes(app_params)
        format.html { redirect_to @app }
        format.js {}
        format.json { render json: @album, location: @album }
      else
        format.html { render action: 'edit' }
        format.js do
          render partial: 'shared/dialog/errors',
                 locals: { resource: @app, action: :update }
        end
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  def destroy
    @app.destroy
    redirect_to apps_path
  end

  # DELETE /apps/1/revoke
  def revoke
    tokens = current_user.tokens.where(app: @app)
    tokens.each(&:delete)
    respond_to do |format|
      format.html { redirect_to(params[:return_uri] || apps_path) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_app
    not_found('app') && return unless App.exists? params[:id]
    @app = App.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def app_params
    params.require(:app).permit(:name, :website, :support_url, :callback_url,
                                :icon_16, :icon_64, :icon_512, :description,
                                :author, :author_url)
  end

  def ensure_owner_or_admin
    access_denied unless current_user.owns?(@app) || current_user.admin?
  end
end
