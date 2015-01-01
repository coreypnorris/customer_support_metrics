require 'spec_helper'

RSpec.describe Person do
  it { should have_many(:owned_conversations).class_name('Conversation').with_foreign_key('owner_id') }
  it { should have_many(:customer_conversations).class_name('Conversation').with_foreign_key('customer_id') }
  it { should have_many(:created_conversations).class_name('Conversation').with_foreign_key('creator_id') }
  it { should have_many(:closed_conversations).class_name('Conversation').with_foreign_key('closer_id') }

  it { should have_many(:assigned_conversation_threads).class_name('ConversationThread').with_foreign_key('assigned_to_id') }
  it { should have_many(:created_conversation_threads).class_name('ConversationThread').with_foreign_key('creator_id') }
  it { should have_many(:customer_conversation_threads).class_name('ConversationThread').with_foreign_key('customer_id') }

  it { should validate_presence_of(:id) }
  it { should validate_uniqueness_of(:id) }
end
