class AddUserToCommentsAndPosts < ActiveRecord::Migration[8.0]
  def change
    change_table :comments do |t|
      t.references :user, null: false, foreign_key: true
    end

    change_table :posts do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
    end
  end
end
