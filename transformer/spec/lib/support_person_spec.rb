require 'spec_helper'

RSpec.describe SupportPerson do
  it { should belong_to(:person) }
end
