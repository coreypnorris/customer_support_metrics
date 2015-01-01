require 'spec_helper'

RSpec.describe ConversationMetric do
  it { should belong_to(:starter).class_name('Person') }

  it { should validate_presence_of(:id) }
  it { should validate_uniqueness_of(:id) }
end
