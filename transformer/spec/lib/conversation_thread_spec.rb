require 'spec_helper'

RSpec.describe ConversationThread do
  it { should belong_to(:conversation) }

  it { should belong_to(:customer).class_name('Person') }
  it { should belong_to(:creator).class_name('Person') }
  it { should belong_to(:assigned_to).class_name('Person') }

  it { should validate_presence_of(:id) }
  it { should validate_uniqueness_of(:id) }
end
