class AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.role.patient?
        scope.where(patient_id: user.id)
      elsif user.role.doctor?
        scope.joins(:schedule).where(schedules: { user_id: user.id })
      else
        scope.all
      end
    end
  end

  def show?
    user_owns_appointment?
  end

  def create?
    user.role.patient?
  end

  def update?
    if user.role.patient?
      record.patient_id == user.id
    elsif user.role.doctor?
      record.schedule.user_id == user.id
    else
      false
    end
  end

  def bulk_update?
    user.role.doctor?
  end

  def destroy?
    user_owns_appointment?
  end

  private

  def user_owns_appointment?
    if user.role.patient?
      return record.patient_id == user.id
    end

    if user.role.doctor?
      return record.schedule.user_id == user.id
    end

    false
  end
end
