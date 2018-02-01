class AddWebsiteidToVacancies < ActiveRecord::Migration[4.2]
  def change
    add_column :vacancies, :website_id, :integer
  end
end
