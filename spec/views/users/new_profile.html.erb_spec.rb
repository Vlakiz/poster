require 'rails_helper'

RSpec.describe "users/new_profile", type: :view do
    let(:user) { build_stubbed(:user) }
    let(:countries) { [ [ "France", "FR" ], [ "United States", "US" ], [ "Poland", "PL" ] ] }

    before do
        assign(:user, user)
        assign(:countries, countries)

        allow(view).to receive(:current_user).and_return(user)

        render
    end

    subject { rendered }

    it "renders new_profile template" do
        is_expected.to have_selector("h2", text: "Create profile")
        is_expected.to have_selector("form")
    end

    it "renders input fields for first name and last name" do
        is_expected.to have_field("user_first_name")
        is_expected.to have_field("user_last_name")
    end

    it "renders submit button" do
        is_expected.to have_button("Save")
    end

    it "forms correct action URL" do
        is_expected.to have_selector("form[action='#{create_profile_users_path}'][method='post']")
    end

    describe "date of birth field" do
        it "has default value to today" do
            is_expected.to have_field("user_date_of_birth", with: Date.today.to_s)
        end
    end

    describe "country select" do
        it "is rendered with valid options" do
            is_expected.to have_select("user_country", options: countries.map(&:first))
        end

        it "preselects United States" do
            is_expected.to have_select("user_country", selected: "United States")
        end
    end
end
