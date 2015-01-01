class AddBasicFieldsToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :conversation_type, :string
    add_column :conversations, :is_draft, :boolean
    add_column :conversations, :number, :integer, :limit => 8
    add_column :conversations, :thread_count, :integer
    add_column :conversations, :status, :string
    add_column :conversations, :subject, :string
    add_column :conversations, :preview, :string
    add_column :conversations, :closed_at, :datetime
    add_column :conversations, :cc, :string
    add_column :conversations, :bcc, :string
    add_column :conversations, :source, :string
  end
end
