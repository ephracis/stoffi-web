# frozen_string_literal: true
class RenameClientApplicationsToApps < ActiveRecord::Migration
  def change
    rename_table :client_applications, :apps
    rename_column :devices, :client_application_id, :app_id
    rename_column :oauth_tokens, :client_application_id, :app_id
  end
end
