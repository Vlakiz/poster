class AddRatingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :rating, :integer, null: false, default: 0
  end
end
