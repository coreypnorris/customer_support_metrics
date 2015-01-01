class Person < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :owned_conversations, -> { uniq }, :class_name => 'Conversation', :foreign_key => :owner_id
  has_many :customer_conversations, -> { uniq }, :class_name => 'Conversation', :foreign_key => :customer_id
  has_many :created_conversations, -> { uniq }, :class_name => 'Conversation', :foreign_key => :creator_id
  has_many :closed_conversations, -> { uniq }, :class_name => 'Conversation', :foreign_key => :closer_id

  has_many :assigned_conversation_threads, -> { uniq }, :class_name => 'ConversationThread', :foreign_key => :assigned_to_id
  has_many :created_conversation_threads, -> { uniq }, :class_name => 'ConversationThread', :foreign_key => :creator_id
  has_many :customer_conversation_threads, -> { uniq }, :class_name => 'ConversationThread', :foreign_key => :customer_id

  validates :id, presence: true, uniqueness: true
end
