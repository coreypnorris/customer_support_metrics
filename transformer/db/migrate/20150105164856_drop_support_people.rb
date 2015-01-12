class DropSupportPeople < ActiveRecord::Migration
  def change
    drop_table :support_people
  end
end
