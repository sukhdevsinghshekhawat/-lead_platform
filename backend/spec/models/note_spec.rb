require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:message) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:lead) }
  end

  describe 'scopes' do
    describe '.newest_first' do
      let!(:lead) { create(:lead) }
      let!(:user) { create(:user) }
      let!(:note1) { create(:note, lead: lead, user: user, created_at: 2.days.ago) }
      let!(:note2) { create(:note, lead: lead, user: user, created_at: 1.day.ago) }

      it 'orders by created_at desc' do
        expect(Note.newest_first.first).to eq(note2)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid note' do
      note = create(:note)
      expect(note).to be_valid
    end
  end
end
