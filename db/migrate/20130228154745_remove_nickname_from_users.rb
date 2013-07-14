class RemoveNicknameFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :nickname
  end

  def down
    add_column :users, :nickname, :string
  end
end
