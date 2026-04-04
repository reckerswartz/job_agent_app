class AddSalaryFieldsToJobListings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_listings, :salary_min, :integer
    add_column :job_listings, :salary_max, :integer
    add_column :job_listings, :salary_currency, :string
    add_column :job_listings, :salary_period, :string
  end
end
