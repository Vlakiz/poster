RSpec.shared_examples 'name' do |attribute_name|
  it { should validate_presence_of(attribute_name).on(:update) }
  it { should validate_length_of(attribute_name).on(:update) }

  it "can't contain number" do
      subject.update(attribute_name => 'Charles 1')
      is_expected.not_to be_valid
      expect(subject.errors[attribute_name]).to include("can only contain letters, spaces, or hyphens")
  end

  it "can't contain special characters" do
      subject.update(attribute_name => 'Hugo_L')
      is_expected.not_to be_valid
      expect(subject.errors[attribute_name]).to include("can only contain letters, spaces, or hyphens")
  end

  it "should be valid if meets requirements" do
      subject.update(attribute_name => 'Anne-Marie van Dijk')
      is_expected.to be_valid
  end
end

RSpec.shared_examples 'invalid unfollow' do |params|
    let(:unfollowing_user) { params[:users_index] && users[params[:users_index]] }

    it 'should not change subscriptions count' do
        expect {
            users[0].unfollow!(unfollowing_user)
        }.not_to change { Subscription.count }
    end

    it 'should return nil' do
        unfollow_result = users[0].unfollow!(unfollowing_user)
        expect(unfollow_result).to be_nil
    end
end
