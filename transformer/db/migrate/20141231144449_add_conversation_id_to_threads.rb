class AddConversationIdToThreads < ActiveRecord::Migration
  def change
    add_column :threads, :conversation_id, :integer, :limit => 8
  end
end
