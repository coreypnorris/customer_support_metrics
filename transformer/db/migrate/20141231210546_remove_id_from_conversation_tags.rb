class RemoveIdFromConversationTags < ActiveRecord::Migration
  def change
    remove_column :conversation_tags, :id
  end
end
