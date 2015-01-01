class AllowNullValuesOnConversationFields < ActiveRecord::Migration
  def change
    change_column :conversations, :conversation_type, :string, :null => true
    change_column :conversations, :is_draft, :boolean, :null => true
    change_column :conversations, :number, :integer, :limit => 8, :null => true
    change_column :conversations, :thread_count, :integer, :null => true
    change_column :conversations, :status, :string, :null => true
    change_column :conversations, :subject, :string, :null => true
    change_column :conversations, :preview, :string, :null => true
    change_column :conversations, :closed_at, :datetime, :null => true
    change_column :conversations, :cc, :string, :null => true
    change_column :conversations, :bcc, :string, :null => true
    change_column :conversations, :source, :string, :null => true
  end
end
