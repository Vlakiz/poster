class AddIndexToPosts < ActiveRecord::Migration[8.0]
  def change
    add_index :posts, :published_at
  end
end
