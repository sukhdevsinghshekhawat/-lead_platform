require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:role) }
  end

  describe 'associations' do
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:assigned_leads).dependent(:nullify) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe 'scopes' do
    describe '.members' do
      it 'returns only members' do
        create(:user, role: :admin)
        create(:user, role: :member)
        expect(User.members.count).to eq(1)
        expect(User.members.first.role).to eq('member')
      end
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = create(:user)
      expect(user).to be_valid
    end

    it 'creates a valid admin' do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end

    it 'creates a valid member' do
      user = create(:user, :member)
      expect(user.member?).to be true
    end
  end
end
