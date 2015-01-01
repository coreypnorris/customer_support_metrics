require 'spec_helper'

RSpec.describe ConversationTag do
  it { should belong_to(:conversation) }
  it { should belong_to(:tag) }

  it { should validate_presence_of(:conversation_id) }
  it { should validate_presence_of(:tag_id) }
end
