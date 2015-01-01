class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people, :id => false do |t|
      t.integer :id, :limit => 8
    end
  end
end
