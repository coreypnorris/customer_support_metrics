class AddMailboxAndTimestampsToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :mailbox, :string, :null => true
    add_column :conversations, :created_at, :datetime, :null => true
    add_column :conversations, :modified_at, :datetime, :null => true
  end
end
