class RenameCreatedAtColumns < ActiveRecord::Migration
  def change
    rename_column :conversation_metrics, :created_at_local, :created_at
    rename_column :conversation_threads, :created_at_utc, :created_at
    rename_column :conversation_threads, :opened_at_utc, :opened_at

    rename_column :conversations, :closed_at_utc, :closed_at
    rename_column :conversations, :created_at_utc, :created_at
    rename_column :conversations, :modified_at_utc, :modified_at
  end
end
