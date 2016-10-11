class AddWebsiteidToVacancies < ActiveRecord::Migration
  def change
    add_column :vacancies, :website_id, :integer
  end
end
