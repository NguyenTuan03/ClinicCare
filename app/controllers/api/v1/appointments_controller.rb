module Api
  module V1
    class AppointmentsController < ApplicationController
      before_action :authorize_request

      def index
        schedule = Appointment.all
        render_success(data: schedule, message: "Success", status: :ok)
      end

      def show
        schedule = Appointment.find_by(id: params[:id])
        if !schedule
          return render_error(message: "Schedule not found", status: :not_found)
        end
        render_success(data: schedule, message: "Success", status: :ok)
      end

      def create
        schedule = Appointment.new(schedule_params)
        puts "current user", @current_user
        # Only doctor can create schedule
        if @current_user.role.name != "doctor"
          return render_error(message: "You don't have permission to create schedule", status: :unauthorized)
        end

        schedule.user_id = @current_user.id

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

        schedule.destroy
        render_success(data: schedule, message: "Success", status: :ok)
      end

      private

      def schedule_params
        params.require(:schedule).permit(:date, :start_time, :end_time)
      end
    end
  end
end
