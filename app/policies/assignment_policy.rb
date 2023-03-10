class AssignmentPolicy < ApplicationPolicy
  def show?
    user.present? && assignment_active?
  end

  def create?
    user.present? && assignment_active?
  end

  def update?
    user.present? && assignment_active?
  end

  private

  def assignment_on_time?
    record.start_date < Time.zone.now && record.end_date > Time.zone.now
  end

  def assignment_active?
    record.active? && assignment_on_time?
  end
end
