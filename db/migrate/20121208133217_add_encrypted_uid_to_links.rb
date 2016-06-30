# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddEncryptedUidToLinks < ActiveRecord::Migration
  def change
    add_column :links, :encrypted_uid, :string
  end
end
