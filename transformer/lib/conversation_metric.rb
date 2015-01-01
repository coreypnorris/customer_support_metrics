class ConversationMetric < ActiveRecord::Base
  self.primary_key = 'id'

  belongs_to :starter, :class_name => 'Person', :foreign_key => :started_by

  validates :id, presence: true, uniqueness: true
end
