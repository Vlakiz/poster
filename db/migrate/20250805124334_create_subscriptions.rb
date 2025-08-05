class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :following, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :subscriptions, [ :follower_id, :following_id ], unique: true

    add_column :users, :followers_count, :integer, default: 0, null: false
    add_column :users, :followings_count, :integer, default: 0, null: false
  end
end
