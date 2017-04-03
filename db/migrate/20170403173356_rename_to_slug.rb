class RenameToSlug < ActiveRecord::Migration[5.0]
  def change
    rename_column :pages, :code, :slug
  end
end
