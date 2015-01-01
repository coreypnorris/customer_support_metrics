class RenameThreadsTable < ActiveRecord::Migration
  def change
    rename_table :threads, :conversation_threads
  end
end
