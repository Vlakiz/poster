class AddRandomSeedToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :random_seed, :float
  end
end
