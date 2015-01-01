require 'spec_helper'

RSpec.describe Conversation do
  it { should belong_to(:owner).class_name('Person') }
  it { should belong_to(:customer).class_name('Person') }
  it { should belong_to(:creator).class_name('Person') }
  it { should belong_to(:closer).class_name('Person') }

  it { should have_many(:conversation_tags) }
  it { should have_many(:tags).through(:conversation_tags) }

  it { should have_many(:conversation_threads) }

  it { should validate_presence_of(:id) }
  it { should validate_uniqueness_of(:id) }
end
