class RenameTeamMembers < ActiveRecord::Migration
  def change
    rename_table(:team_members, :support_people)
  end
end
