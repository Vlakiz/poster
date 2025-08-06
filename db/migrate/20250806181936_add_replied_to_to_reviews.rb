class AddRepliedToToReviews < ActiveRecord::Migration[8.0]
  def change
    change_table :comments do |t|
      t.references :replied_to, index: true, null: true, foreign_key: { to_table: :comments }
    end
  end
end
