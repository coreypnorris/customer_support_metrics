class ConversationThread < ActiveRecord::Base
  self.primary_key = 'id'

  belongs_to :conversation

  belongs_to :customer, :class_name => 'Person'
  belongs_to :creator, :class_name => 'Person'
  belongs_to :assigned_to, :class_name => 'Person'

  validates :id, presence: true, uniqueness: true
end
