class ChangeRegistrationDateTypeInUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :registration_date, :signed_up_at
    change_column :users, :signed_up_at, :datetime
  end
end
