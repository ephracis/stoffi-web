# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Handle requests for searching.
#
# Flow:
#  1. User enters query into search box
#  2. suggest() fetches similar search queries for auto-complete
#  3. User presses Enter
#  4. index() saves the query and renders a skeleton result view
#  5. The view uses AJAX to load the actual results from fetch()
#  6. fetch() sends query to backends in search/ folder
#  7. The results are injected into the page
#
# For API calls the index() method will directly fetch results
# and return them.
class SearchController < ApplicationController
  def suggestions
    @query = query_param
    @suggestions = []
    if @query.present?
      page = request.referer
      pos = origin_position(request.remote_ip)
      long = pos[:longitude]
      lat = pos[:latitude]
      loc = I18n.locale.to_s
      user = user_signed_in? ? current_user.id : -1
      cat = category_param
      cat = [] if cat == Search.categories
      @suggestions = Search.suggest(@query, page, long, lat, loc, cat, user)
    end
  end

  def index
    @search = new_search
    backends = params[:backends].present?
    respond_to do |format|
      format.html { render }
      format.js { @results = @search.do(page_param, limit_param, backends) }
      format.json { @results = @search.do(page_param, limit_param, backends) }
    end
  end

  private

  def query_param
    q = params[:q] || params[:query] || params[:term] || ''
    CGI.escapeHTML(q)
  end

  def category_param
    x = params[:c] || params[:cat] || params[:categories] || params[:category]
    x = Search.categories if x.to_s == 'all'
    x ? x.split(/[\|,]/) : Search.categories
  end

  def source_param
    x = params[:s] || params[:src] || params[:sources] || params[:source]
    x = Search.sources if x.to_s == 'all'
    x ? x.split(/[\|,]/) : Search.sources
  end

  def limit_param
    [50, (params[:limit] || '20').to_i].min
  end

  def page_param
    (params[:p] || params[:page] || '1').to_i
  end

  # create a search object
  def new_search
    pos = origin_position(request.remote_ip)
    s = Search.new
    s.query = query_param
    s.longitude = pos[:longitude]
    s.latitude = pos[:latitude]
    s.locale = I18n.locale.to_s
    s.categories = category_param.sort.join('|')
    s.sources = source_param.sort.join('|')
    s.page = request.referer || ''
    s.user = current_user if user_signed_in?
    s.save if s.query.present?
    s
  end
end
