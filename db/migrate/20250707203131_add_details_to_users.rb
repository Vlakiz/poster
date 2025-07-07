class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, null: false, limit: 70, default: "Unknown"
    add_column :users, :last_name, :string, null: false, limit: 70, default: "Unknown"
    add_column :users, :date_of_birth, :date, null: false, default: "2000-01-01"
    add_column :users, :registration_date, :date, null: false, default: "2000-01-01"
    add_column :users, :country, :string, null: false, default: "US", limit: 2
  end
end
