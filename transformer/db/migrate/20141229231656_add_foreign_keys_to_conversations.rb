class AddForeignKeysToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :owner_id, :integer, :limit => 8
    add_column :conversations, :customer_id, :integer, :limit => 8
    add_column :conversations, :creator_id, :integer, :limit => 8
    add_column :conversations, :closed_by_id, :integer, :limit => 8
  end
end
