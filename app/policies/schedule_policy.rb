class SchedulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.role.patient?
        # Patients only see free schedules (no active appointments)
        scope.where.not(
          id: Appointment.where(status: [ :pending, :confirmed ]).select(:schedule_id)
        )
      elsif user.role.doctor?
        # Doctors see their own schedules
        scope.where(user_id: user.id)
      else
        scope.all
      end
    end
  end

  def show?
    true
  end

  def create?
    user.role.doctor?
  end

  def update?
    user.role.doctor? && record.user_id == user.id
  end

  def destroy?
    user.role.doctor? && record.user_id == user.id
  end
end
