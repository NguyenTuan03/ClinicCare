class Api::V1::SchedulesController < ApplicationController
  before_action :authorize_request

  def index
    schedules = policy_scope(Schedule)

    if params[:user_id].present?
      schedules = schedules.where(user_id: params[:user_id])
    end

    render_success(data: serialize_schedule(schedules), message: "Success", status: :ok)
  end

  def show
    schedule = Schedule.find_by(id: params[:id])
    if !schedule
      return render_error(message: "Schedule not found", status: :not_found)
    end

    authorize schedule

    render_success(data: serialize_schedule(schedule), message: "Success", status: :ok)
  end

  def create
    schedule = Schedule.new(schedule_params)
    schedule.user_id = @current_user.id

    authorize schedule

    if schedule.save
      render_success(data: schedule, message: "Success", status: :created)
    else
      render_error(message: schedule.errors.full_messages, status: :unprocessable_entity)
    end
  end

  def update
    schedule = Schedule.find_by(id: params[:id])
    if !schedule
      return render_error(message: "Schedule not found", status: :not_found)
    end

    authorize schedule

    if schedule.update(schedule_params)
      render_success(data: schedule, message: "Success", status: :ok)
    else
      render_error(data: schedule.errors, message: "Failed", status: :unprocessable_entity)
    end
  end

  def destroy
    schedule = Schedule.find_by(id: params[:id])
    if !schedule
      return render_error(message: "Schedule not found", status: :not_found)
    end

    authorize schedule

    schedule.destroy
    render_success(data: schedule, message: "Success", status: :ok)
  end

  private

  def schedule_params
    params.require(:schedule).permit(:date, :start_time, :end_time)
  end

  def serialize_schedule(data)
    data.as_json(
      include: {
        user: {
          only: [ :name, :email ],
          include: {
            role: { only: [ :id, :name ] }
          }
        }
      }
    )
  end
end
