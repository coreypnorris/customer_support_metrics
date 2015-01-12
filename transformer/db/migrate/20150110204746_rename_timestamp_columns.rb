class RenameTimestampColumns < ActiveRecord::Migration
  def change
    rename_column :conversation_metrics, :created_at_utc, :created_at_local
    rename_column :conversation_threads, :created_at, :created_at_utc
    rename_column :conversation_threads, :opened_at, :opened_at_utc

    rename_column :conversations, :closed_at, :closed_at_utc
    rename_column :conversations, :created_at, :created_at_utc
    rename_column :conversations, :modified_at, :modified_at_utc
  end
end
