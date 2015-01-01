require 'spec_helper'

RSpec.describe Tag do
  it { should have_many(:conversation_tags) }
  it { should have_many(:conversations).through(:conversation_tags) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
