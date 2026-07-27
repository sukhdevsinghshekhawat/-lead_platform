require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:action) }
  end

  describe 'associations' do
    it { should belong_to(:lead) }
    it { should belong_to(:user).optional }
  end

  describe 'scopes' do
    describe '.newest_first' do
      let!(:lead) { create(:lead) }
      let!(:user) { create(:user) }
      let!(:activity1) { create(:activity, lead: lead, user: user, created_at: 2.days.ago) }
      let!(:activity2) { create(:activity, lead: lead, user: user, created_at: 1.day.ago) }

      it 'orders by created_at desc' do
        expect(Activity.newest_first.first).to eq(activity2)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid activity' do
      activity = create(:activity)
      expect(activity).to be_valid
    end

    it 'creates an activity without user' do
      activity = create(:activity, user: nil)
      expect(activity).to be_valid
    end
  end
end
