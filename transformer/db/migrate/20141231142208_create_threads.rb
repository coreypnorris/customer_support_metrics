require "active_support/all"

class CreateThreads < ActiveRecord::Migration
  def change
    create_table :threads, :id => false do |t|
      t.integer :id, :limit => 8
      t.string :thread_type
      t.integer :assigned_to_id, :limit => 8
      t.string :status
      t.datetime :created_at
      t.datetime :opened_at
      t.integer :creator_id, :limit => 8
      t.string :source
      t.string :action_type
      t.integer :action_source_id
      t.string :from_mailbox
      t.string :state
      t.integer :customer_id, :limit => 8
      t.text :body, :limit => 64.kilobytes + 1
      t.text :to, :limit => 64.kilobytes + 1
      t.text :cc, :limit => 64.kilobytes + 1
      t.text :bcc, :limit => 64.kilobytes + 1
    end
  end
end
