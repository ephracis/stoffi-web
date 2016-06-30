# frozen_string_literal: true
class ChangeUrlToWebsiteInClientApplications < ActiveRecord::Migration
  def change
    rename_column :client_applications, :url, :website
  end
end
