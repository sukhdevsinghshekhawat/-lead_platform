require 'rails_helper'

RSpec.describe Lead, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:status) }
  end

  describe 'associations' do
    it { should belong_to(:assigned_to).optional }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_many(:activities).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(new_lead: 0, contacted: 1, qualified: 2, proposal_sent: 3, won: 4, lost: 5) }
  end

  describe 'scopes' do
    let!(:lead1) { create(:lead, status: :new_lead) }
    let!(:lead2) { create(:lead, status: :contacted) }
    let!(:lead3) { create(:lead, status: :qualified) }

    describe '.by_status' do
      it 'filters by status' do
        expect(Lead.by_status('new_lead').count).to eq(1)
        expect(Lead.by_status('contacted').count).to eq(1)
      end

      it 'returns all when status is nil' do
        expect(Lead.by_status(nil).count).to eq(3)
      end
    end

    describe '.by_assigned_user' do
      let!(:user) { create(:user) }
      let!(:lead4) { create(:lead, assigned_to: user) }

      it 'filters by assigned user' do
        expect(Lead.by_assigned_user(user.id).count).to eq(1)
      end

      it 'returns all when user_id is nil' do
        expect(Lead.by_assigned_user(nil).count).to eq(4)
      end
    end

    describe '.search' do
      it 'searches by name' do
        expect(Lead.search(lead1.name).count).to eq(1)
      end

      it 'searches by email' do
        expect(Lead.search(lead1.email).count).to eq(1)
      end

      it 'returns all when query is blank' do
        expect(Lead.search('').count).to eq(3)
      end
    end

    describe '.newest_first' do
      it 'orders by created_at desc' do
        expect(Lead.newest_first.first).to eq(lead3)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid lead' do
      lead = create(:lead)
      expect(lead).to be_valid
      expect(lead.status).to eq('new_lead')
    end

    it 'creates a lead with assignment' do
      user = create(:user)
      lead = create(:lead, assigned_to: user)
      expect(lead.assigned_to).to eq(user)
    end
  end
end
