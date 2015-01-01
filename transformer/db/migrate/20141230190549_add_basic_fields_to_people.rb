class AddBasicFieldsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :first_name, :string, :null => true
    add_column :people, :last_name, :string, :null => true
    add_column :people, :email, :string, :null => true
    add_column :people, :phone, :string, :null => true
    add_column :people, :type, :string, :null => true

    rename_column :conversations, :closed_by_id, :closer_id
  end
end
