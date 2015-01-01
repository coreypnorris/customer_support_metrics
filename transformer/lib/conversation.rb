class Conversation < ActiveRecord::Base
  self.primary_key = 'id'

  belongs_to :owner, :class_name => 'Person'
  belongs_to :customer, :class_name => 'Person'
  belongs_to :creator, :class_name => 'Person'
  belongs_to :closer, :class_name => 'Person'

  has_many :conversation_tags, dependent:  :destroy
  has_many :tags, -> { uniq }, :through => :conversation_tags

  has_many :conversation_threads, -> { uniq }

  validates :id, presence: true, uniqueness: true
end
