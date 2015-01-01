class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations, :id => false do |t|
      t.integer :id, :limit => 8
    end
  end
end
