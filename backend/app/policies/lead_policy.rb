class LeadPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    admin? || record.assigned_to_id == user.id
  end

  def create?
    true
  end

  def update?
    admin? || record.assigned_to_id == user.id
  end

  def destroy?
    admin?
  end

  def assign?
    admin?
  end

  def update_status?
    admin? || record.assigned_to_id == user.id
  end

  def add_note?
    admin? || record.assigned_to_id == user.id
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(assigned_to_id: user.id)
      end
    end
  end

  private

  def admin?
    user.admin?
  end
end

