class RenameConversationsTags < ActiveRecord::Migration
  def change
    rename_table(:conversations_tags, :conversation_tags)
  end
end
