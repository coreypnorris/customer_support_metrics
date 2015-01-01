class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members, :id => false do |t|
      t.integer :id, :limit => 8
    end
  end
end
