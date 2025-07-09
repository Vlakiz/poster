class AddCommentsCountToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :comments_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up { Post.find_each { |post| Post.reset_counters(post.id, :comments) } }
    end
  end
end
