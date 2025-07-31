require 'rails_helper'

RSpec.describe User, type: :model do
    describe 'validators' do
        it { should validate_presence_of(:nickname) }
    end

    describe 'associations' do
        it { should have_many(:posts) }
        it { should have_many(:comments) }
    end
end
