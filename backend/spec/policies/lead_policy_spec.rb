require 'rails_helper'

RSpec.describe LeadPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user, :member) }
  let(:other_member) { create(:user, :member) }
  let(:assigned_lead) { create(:lead, assigned_to: member) }
  let(:unassigned_lead) { create(:lead, assigned_to: nil) }

  permissions :index? do
    it 'allows admin' do
      expect(described_class.new(admin, Lead).index?).to be true
    end

    it 'allows member' do
      expect(described_class.new(member, Lead).index?).to be true
    end
  end

  permissions :show? do
    it 'allows admin' do
      expect(described_class.new(admin, assigned_lead).show?).to be true
    end

    it 'allows assigned member' do
      expect(described_class.new(member, assigned_lead).show?).to be true
    end

    it 'denies non-assigned member' do
      expect(described_class.new(other_member, assigned_lead).show?).to be false
    end
  end

  permissions :create? do
    it 'allows admin' do
      expect(described_class.new(admin, Lead).create?).to be true
    end

    it 'allows member' do
      expect(described_class.new(member, Lead).create?).to be true
    end
  end

  permissions :update? do
    it 'allows admin' do
      expect(described_class.new(admin, assigned_lead).update?).to be true
    end

    it 'allows assigned member' do
      expect(described_class.new(member, assigned_lead).update?).to be true
    end

    it 'denies non-assigned member' do
      expect(described_class.new(other_member, assigned_lead).update?).to be false
    end
  end

  permissions :destroy? do
    it 'allows admin' do
      expect(described_class.new(admin, assigned_lead).destroy?).to be true
    end

    it 'denies member' do
      expect(described_class.new(member, assigned_lead).destroy?).to be false
    end
  end

  permissions :assign? do
    it 'allows admin' do
      expect(described_class.new(admin, assigned_lead).assign?).to be true
    end

    it 'denies member' do
      expect(described_class.new(member, assigned_lead).assign?).to be false
    end
  end

  permissions :update_status? do
    it 'allows admin' do
      expect(described_class.new(admin, assigned_lead).update_status?).to be true
    end

    it 'allows assigned member' do
      expect(described_class.new(member, assigned_lead).update_status?).to be true
    end

    it 'denies non-assigned member' do
      expect(described_class.new(other_member, assigned_lead).update_status?).to be false
    end
  end

  permissions :add_note? do
    it 'allows admin' do
      expect(described_class.new(admin, assigned_lead).add_note?).to be true
    end

    it 'allows assigned member' do
      expect(described_class.new(member, assigned_lead).add_note?).to be true
    end

    it 'denies non-assigned member' do
      expect(described_class.new(other_member, assigned_lead).add_note?).to be false
    end
  end

  describe 'Scope' do
    it 'returns all leads for admin' do
      scope = LeadPolicy::Scope.new(admin, Lead.all).resolve
      expect(scope.count).to eq(Lead.count)
    end

    it 'returns only assigned leads for member' do
      create(:lead, assigned_to: member)
      create(:lead, assigned_to: nil)
      scope = LeadPolicy::Scope.new(member, Lead.all).resolve
      expect(scope.count).to eq(1)
    end
  end
end
