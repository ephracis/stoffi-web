# frozen_string_literal: true
class AddIcon512ToClientApplications < ActiveRecord::Migration
  def change
    add_column :client_applications, :icon_512, :string
  end
end
