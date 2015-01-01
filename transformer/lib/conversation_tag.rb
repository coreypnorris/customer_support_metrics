class ConversationTag < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :tag

  validates_presence_of :conversation_id
  validates_presence_of :tag_id
  validates_uniqueness_of :conversation_id, :scope => :tag_id
end
