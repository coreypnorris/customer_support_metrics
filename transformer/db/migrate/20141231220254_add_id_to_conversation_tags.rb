class AddIdToConversationTags < ActiveRecord::Migration
  def change
    add_column :conversation_tags, :id, :primary_key
  end
end
