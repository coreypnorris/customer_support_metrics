class Tag < ActiveRecord::Base
  has_many :conversation_tags, dependent:  :destroy
  has_many :conversations, -> { uniq }, :through => :conversation_tags

  validates :name, presence: true, uniqueness: true
end
