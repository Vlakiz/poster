class AddRepliesCountToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :replies_count, :integer, default: 0, null: false
  end
end
