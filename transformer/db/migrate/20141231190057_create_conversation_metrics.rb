class CreateConversationMetrics < ActiveRecord::Migration
  def change
    create_table :conversation_metrics, :id => false do |t|
      t.integer :id, :limit => 8
      t.string :url
      t.datetime :created_at_utc
      t.integer :first_response_duration, :limit => 8
      t.string :status
      t.boolean :during_business_hours
      t.boolean :special_case
      t.integer :started_by, :limit => 8
    end
  end
end
