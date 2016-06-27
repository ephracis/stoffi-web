class DropVotesAndTranslations < ActiveRecord::Migration
  def change
  drop_table :admin_translatees
  drop_table :admin_translation_parameters
  drop_table :admin_translatees_admin_translatee_params
  drop_table :languages
  drop_table :votes
  drop_table :translations
  end
end
