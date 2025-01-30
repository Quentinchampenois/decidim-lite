class AddWeightToScopes < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_scopes, :weight, :integer, default: 0
  end
end
