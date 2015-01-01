class CreateConversationsTags < ActiveRecord::Migration
  def change
    create_table :conversations_tags do |t|
      t.integer :conversation_id, :limit => 8
      t.integer :tag_id
    end
  end
end
